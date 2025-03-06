class ServicePaymentReporter
  require 'prawn'
  require 'open-uri'

  def initialize(service_payment, company)
    @service_payment = service_payment
    @company = company
    @pdf = Prawn::Document.new(
      page_size: 'LETTER',
      margin: [40, 40, 40, 40],
      info: {
        Title: "Service Payment Report",
        Author: @company.name,
        Subject: "Payment Report for #{@service_payment.contractor.full_name}",
        Keywords: "payment, report, service",
        CreationDate: Time.now
      }
    )
    @document_width = @pdf.bounds.width

    report_config = @company.report_configurations
                .where(report_type: ["service_payment", "payroll"])
                .order(Arel.sql("CASE report_type WHEN 'service_payment' THEN 1 WHEN 'payroll' THEN 2 END"))
                .first

    layout = report_config&.layout_2 || {}

    @header_background = layout['header_background']   || 'EDEFF5'
    @header_text_color = layout['header_text_color']   || '000000'
    @table_header_bg   = layout['table_header_background'] || '051245'
    @table_header_text = layout['table_header_text_c']   || 'FFFFFF'
    @table_bg_fr1      = layout['table_background_1']  || 'F0F0F0'
    @table_bg_fr2      = layout['table_background_2']  || 'FFFFFF'
    @table_text_c1     = layout['table_text_color1'] || '000000'
    @table_text_c2     = layout['table_text_color2'] || '000000'
    @table_sub_total_bg = layout['table_subtotal_background_2'] || 'DFF0D8'
    @table_sub_total_text = layout['table_subtotal_text_color2'] || '000000'
  end

  def generate
    header
    @pdf.move_down 20
    contractor_information
    @pdf.move_down 20
    
    # Create a single table with two columns
    @pdf.table([
      [service_payment_information, service_payment_deduction]
    ], {
      column_widths: [@document_width/2, @document_width/2],
      cell_style: { borders: [] }
    })
    
    @pdf.move_down 20
    footer
    @pdf
  end

  private

  def header
    # Logo and company information
    logo_cell = if @company.photo.key.present?
      logo_url = cloudinary_logo_url(@company.photo.key)
      begin
        logo_file = URI.open(logo_url)
        { image: logo_file, fit: [80, 80], position: :center }
      rescue OpenURI::HTTPError => e
        "LOGO (Error: #{e.message})"
      end
    else
      "LOGO (Missing)"
    end

    company_info = [
      [@company.name],
      [@company.postal_address],
      ["Tel: #{@company.contact_phone} | Email: #{@company.contact_email}"]
    ]

    company_info_table = @pdf.make_table(company_info, width: @document_width - 300) do |table|
      table.row(0).style(size: 18, align: :center, text_color: @header_text_color, font_style: :bold)
      table.row(1..2).style(size: 9, align: :center, text_color: @header_text_color)
      table.row(0..2).border_width = 0
    end

    header_data = [[logo_cell, company_info_table, "TALONARIO"]]
    header_options = {
      column_widths: [80, @document_width-280, 200],
      row_colors: [@header_background],
      cell_style: {
        border_width: 0,
        padding: 3
      }
    }

    header_table = @pdf.make_table(header_data, header_options)
    header_table.row(0).column(2).style(
      text_color: @header_text_color,
      font_style: :bold,
      size: 16,
      valign: :center
    )

    header_table.row(0).column(1).style(
      align: :center,
      valign: :center
    )

    header_table.draw
  end

  def contractor_information
    employee_data = [
      ["NOMBRE", @service_payment.contractor.full_name],
      ["DIRECCIÓN FÍSICA", @service_payment.contractor.address_line],
      ["CIUDAD, PAÍS Y ZIPCODE", "#{@service_payment.contractor.city}, #{@service_payment.contractor.country}, #{@service_payment.contractor.zip_code}"],
      ["TELÉFONO", @service_payment.contractor.phone_number],
      ["EMAIL", @service_payment.contractor.email]
    ]

    employee_table = @pdf.make_table(employee_data, cell_style: { borders: [], padding: 5, size: 10 })

    @pdf.table([
      ["Información del Empleado", "Fecha de Pago", "Periodo"],
      [employee_table, @service_payment.payment_date.strftime('%d/%m/%Y'), "#{@service_payment.period_start.strftime('%d/%m/%Y')} - #{@service_payment.period_end.strftime('%d/%m/%Y')}"]
    ], {
      column_widths: [@document_width*0.7, @document_width*0.15, @document_width*0.15],
      cell_style: {
        border_width: 0,
        font_style: :bold,
        size: 10,
        padding: 5
      }
    }) do |table|
      table.row(0).style(
        text_color: @table_header_text,
        font_style: :bold,
        size: 12,
        background_color: @table_header_bg
      )
    end
  end

  def service_payment_information
    income_data = [
      ["Pagos a Individuos No Sujetos a Retención", @service_payment.paid_to_individuals_no_retention, @service_payment.calculate_year_to_date("paid_to_individuals_no_retention")],
      ["Pagos a Corporaciones No Sujetos a Retención", @service_payment.paid_to_corporation_no_retention, @service_payment.calculate_year_to_date("paid_to_corporation_no_retention")],
      ["Pagos a Individuos Sujetos a Retención", @service_payment.paid_to_individuals_with_retention, @service_payment.calculate_year_to_date("paid_to_individuals_with_retention")],
      ["Pagos a Corporaciones Sujetos a Retención", @service_payment.paid_to_corporation_with_retention, @service_payment.calculate_year_to_date("paid_to_corporation_with_retention")],
      ["Gastos Rembolsados", @service_payment.reimbursed_expenses, @service_payment.calculate_year_to_date("reimbursed_expenses")],
      ["Pago a Proveedores de Salud", @service_payment.responsibility_payment_health_providers, @service_payment.calculate_year_to_date("responsibility_payment_health_providers")],
      ["Aportación especial por Servicios Profesionales y Consultivos bajo la Ley 48-2013", @service_payment.special_contribution_services, @service_payment.calculate_year_to_date("special_contribution_services")]
    ]

    total_actual = income_data.sum { |row| row[1].to_f }
    total_ytd = income_data.sum { |row| row[2].to_f }

    income_data << ["Total de Ingresos", total_actual, total_ytd]

    @pdf.make_table(
      [["Ingresos", "Actual", "YTD"]] + income_data,
      header: true,
      row_colors: [@table_bg_fr1, @table_bg_fr2],
      width: @document_width/2 - 20,
      column_widths: { 0 => (@document_width/2 - 20)*0.5, 1 => (@document_width/2 - 20)*0.25, 2 => (@document_width/2 - 20)*0.25 },
      cell_style: { 
        borders: [], 
        size: 9,
        padding: 5,
        align: :left
      }
    ) do |table|
      total_row_index = income_data.size
      (1..(total_row_index-1)).each do |row_index|
        text_color = row_index.even? ? @table_text_c1 : @table_text_c2
        table.row(row_index).style(text_color: text_color)
      end

      table.row(0).style(
        text_color: @table_header_text,
        font_style: :bold,
        size: 10,
        background_color: @table_header_bg,
        align: :center
      )

      table.row(total_row_index).style(
        font_style: :bold,
        background_color: @table_sub_total_bg,
        size: 10,
        text_color: @table_sub_total_text,
        align: :center
      )
    end
  end

  def service_payment_deduction
    deductions_data = [
      ["Retención a Individuos", @service_payment.retention_individuals, @service_payment.calculate_year_to_date("retention_individuals")],
      ["Retención a Corporaciones", @service_payment.retention_corporations, @service_payment.calculate_year_to_date("retention_corporations")]
    ]

    total_actual = deductions_data.sum { |row| row[1].to_f }
    total_ytd = deductions_data.sum { |row| row[2].to_f }

    deductions_data << ["Total de Deducciones", total_actual, total_ytd]

    @pdf.make_table(
      [["Deducciones", "Actual", "YTD"]] + deductions_data,
      header: true,
      row_colors: [@table_bg_fr1, @table_bg_fr2],
      width: @document_width/2 - 20,
      column_widths: { 0 => (@document_width/2 - 20)*0.5, 1 => (@document_width/2 - 20)*0.25, 2 => (@document_width/2 - 20)*0.25 },
      cell_style: { 
        borders: [], 
        size: 9,
        padding: 5,
        align: :left
      }
    ) do |table|
      total_row_index = deductions_data.size
      (1..(total_row_index-1)).each do |row_index|
        text_color = row_index.even? ? @table_text_c1 : @table_text_c2
        table.row(row_index).style(text_color: text_color)
      end

      table.row(0).style(
        text_color: @table_header_text,
        font_style: :bold,
        size: 10,
        background_color: @table_header_bg,
        align: :center
      )

      table.row(total_row_index).style(
        font_style: :bold,
        background_color: @table_sub_total_bg,
        size: 10,
        text_color: @table_sub_total_text,
        align: :center
      )
    end
  end

  def footer
    @pdf.move_down 40
    
    footer_text = [
      "Este documento es una copia electrónica válida.",
      "Generado el #{Time.now.strftime('%d/%m/%Y %H:%M')}",
      "© #{Time.now.year} #{@company.name}. Todos los derechos reservados."
    ]

    footer_table = @pdf.make_table([footer_text], cell_style: { 
      borders: [], 
      align: :center,
      size: 8,
      color: '666666'
    })
    footer_table.draw
  end

  def cloudinary_logo_url(photo_key)
    base_url = "https://res.cloudinary.com/dt7l4axew/image/upload/c_fill,h_250,w_250/f_jpg/v1/"
    environment = Rails.env.production? ? "production" : "development"
    base_url + environment + "/" + photo_key
  end
end
