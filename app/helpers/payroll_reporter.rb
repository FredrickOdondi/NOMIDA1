class PayrollReporter
  require 'prawn'
  require 'open-uri'

  def initialize(payroll, company)
    @payroll = payroll
    @company = company
    @pdf = Prawn::Document.new(
      page_size: 'LETTER',
      margin: [40, 40, 40, 40],
      info: {
        Title: "Payroll Report",
        Author: @company.name,
        Subject: "Payroll Report for #{@payroll.employee.first_name} #{@payroll.employee.last_name}",
        Keywords: "payroll, report",
        CreationDate: Time.now
      }
    )
    @document_width = @pdf.bounds.width

    report_config = @company.report_configurations
                .where(report_type: ["payroll", "service_payment"])
                .order(Arel.sql("CASE report_type WHEN 'payroll' THEN 1 WHEN 'service_payment' THEN 2 END"))
                .first

    layout = report_config&.layout_2 || {}

    @header_background = layout['header_background']   || 'EDEFF5'
    @header_text_color = layout['header_text_color']   || '000000'
    @table_header_bg   = layout['table_header_background'] || '051245'
    @table_header_text = layout['table_header_text_c']  || 'FFFFFF'
    @table_bg_fr1      = layout['table_background_1']  || 'F0F0F0'
    @table_bg_fr2      = layout['table_background_2']  || 'FFFFFF'
    @table_text_c1     = layout['table_text_color1'] || '000000'
    @table_text_c2     = layout['table_text_color2'] || '000000'
    @table_sub_total_bg = layout['table_subtotal_background_2'] || 'DFF0D8'
    @table_sub_total_text = layout['table_subtotal_text_color2'] || '000000'
  end

  def generate
    header
    employee_information
    payroll_information
    deductions
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
        { image: logo_file, fit: [100, 100], position: :center }
      rescue OpenURI::HTTPError => e
        "LOGO (Error: #{e.message})"
      end
    else
      "LOGO (Missing)"
    end

    companty_info = [[@company.name], [@company.postal_address], ["# de Teléfono: #{@company.contact_phone}  Email: #{@company.contact_email}"]]

    companty_info_table = @pdf.make_table(companty_info, width: @document_width - 260) do |table|
      table.row(0).style(size: 18, align: :center, text_color: @header_text_color)
      table.row(1..2).style(size: 10, align: :center, text_color: @header_text_color)
      table.row(0..2).border_width = 0
    end

    header_data = [[logo_cell, companty_info_table, "TALONARIO"]]
    header_options = {
      column_widths: [110, @document_width-260, 150],
      row_colors: [@header_background],
      cell_style: {
        border_width: 0
      }
    }

    # Crear la tabla
    header_table = @pdf.make_table(header_data, header_options)

    # Modificar estilo de la celda en la fila 1, columna 3 (índice 0 para fila y columna)
    header_table.row(0).column(2).style(
      text_color: @header_text_color,        # Cambia el color del texto a negro
      font_style: :bold,           # Cambia el estilo de fuente a negrita
      size: 24,                     # Cambia el tamaño de la fuente a 14
      valign: :center
    )

    header_table.row(0).column(1).style(
      align: :center,
      valign: :center
    )
    # Dibujar la tabla
    header_table.draw
  end

  def employee_information
    # employee information section
    @pdf.move_down 20

    employee_data = [
      ["NOMBRE", "#{@payroll.employee.first_name} #{@payroll.employee.last_name}"],
      ["DIRECCIÓN FÍSICA", @payroll.employee.address_line],
      ["CIUDAD, PAÍS Y ZIPCODE", "#{@payroll.employee.city}, #{@payroll.employee.country}, #{@payroll.employee.zip_code}"],
      ["TELÉFONO", @payroll.employee.phone_number],
      ["EMAIL", @payroll.employee.email],
      ["SALARIO POR HORA", @payroll.hourly_rate],
      ["SALARIO FIJO", @payroll.fixed_salary]
    ]
    employee_table = @pdf.make_table(employee_data, cell_style: { borders: [], padding: 2, size: 9 })

    @pdf.table([["Información del Empleado", "Fecha de Pago", "Periodo" ],[employee_table,"#{@payroll.pay_date.strftime('%d/%m/%Y')}"," #{@payroll.period_start.strftime('%d/%m/%Y')} - #{@payroll.period_end.strftime('%d/%m/%Y')}"]],
      {
      column_widths: [@document_width*0.8, @document_width*0.1, @document_width*0.1],
      cell_style: {
        border_width: 0,
        font_style: :bold,
        size: 8

      }
    }) do |table|
      table.row(0).style(
        text_color: @table_header_text,        # Cambia el color del texto a negro
        font_style: :bold,           # Cambia el estilo de fuente a negrita
        size: 10,                    # Cambia el tamaño de la fuente a 12
        background_color: @table_header_bg # Cambia el color de fondo
      )
    end
  end

  def payroll_information
    # payroll information section
    @pdf.move_down 10
    income_data = [
      ["Paga Regular", @payroll.regular_hours.to_s, (@payroll.regular_hours.to_f* @payroll.hourly_rate.to_f), @payroll.calculate_year_to_date("regular_hours_payment")],
      ["Paga Extra", @payroll.overtime_hours.to_s, (@payroll.overtime_hours.to_f * @payroll.hourly_rate.to_f * 1.5), @payroll.calculate_year_to_date("overtime_hours_payment")],
      ["Paga por Vacaciones", @payroll.vacation_hours.to_s, (@payroll.vacation_hours.to_f * @payroll.hourly_rate.to_f), @payroll.calculate_year_to_date("vacation_hours_payment")],
      ["Paga por Enfermedad", @payroll.sick_hours.to_s, (@payroll.sick_hours.to_f * @payroll.hourly_rate.to_f), @payroll.calculate_year_to_date("sick_hours_payment")],
      ["Salario Fijo", nil, @payroll.fixed_salary.to_s, @payroll.calculate_year_to_date("fixed_salary")],
      # special payments
      ["Propinas",nil, @payroll.tips.to_s, @payroll.calculate_year_to_date("tips").to_s],
      ["Comisiones", nil, @payroll.commissions.to_s, @payroll.calculate_year_to_date("commissions").to_s],
      ["Bonos", nil, @payroll.bonuses.to_s, @payroll.calculate_year_to_date("bonuses").to_s],
      ["Otros Pagos Sujetos a Contribuciones", nil, @payroll.other_payments_subject_to_contribution.to_s, @payroll.calculate_year_to_date("other_payments_subject_to_contribution").to_s],
      ["Otros Pagos Sujetos a Contribuciones", nil, @payroll.other_payments_subject_to_contribution_2.to_s, @payroll.calculate_year_to_date("other_payments_subject_to_contribution_2").to_s],
      ["Rembolso de gastos", nil, @payroll.expense_reimbursement.to_s, @payroll.calculate_year_to_date("expense_reimbursement").to_s],
      ["Allowances", nil, @payroll.allowances.to_s, @payroll.calculate_year_to_date("allowances").to_s],
      ["Otros Pagos no sujetos a retenciones", nil, @payroll.other_payments_not_subject_to_retention.to_s, @payroll.calculate_year_to_date("other_payments_not_subject_to_retention").to_s]
    ]

    # Calculate totals
    total_actual = income_data.sum { |row| row[2].to_f }
    total_ytd = income_data.sum { |row| row[3].to_f }

    # Append total row
    income_data << ["Total Ingresos", nil, total_actual.round(2), total_ytd.round(2)]

    @pdf.table(
      [["Ingresos", "Horas", "Actual", "YTD"]] + income_data,
      header: true,
      row_colors: [@table_bg_fr1 , @table_bg_fr2 ],

      position: :center,
      column_widths: { 0 => @document_width*0.5, 1 => @document_width/6, 2 => @document_width/6, 3 => @document_width/6}, # Adjust column widths here
      cell_style: { borders: [], size: 9 }
    ) do |table|

      # Style total row
      total_row_index = income_data.size # Last row is the total row

      # Style all rows except the last (subtotal)
      (1..(total_row_index-1)).each do |index|
        text_color = (index.even? ? @table_text_c1 : @table_text_c2) # Alternate text colors
        table.row(index).style(text_color: text_color)
      end

      # Style header row
      table.row(0).style(
      text_color: @table_header_text,        # Cambia el color del texto a negro
      font_style: :bold,           # Cambia el estilo de fuente a negrita
      size: 10,                    # Cambia el tamaño de la fuente a 12
      background_color: @table_header_bg   # Cambia el color de fondo
      )

      table.row(total_row_index).style(
        font_style: :bold,
        background_color: @table_sub_total_bg, # Light green background
        text_color: @table_sub_total_text,
        size: 10
      )

    end
  end

  def deductions
    # deductions section
    @pdf.move_down 10
    deductions_data = [
      ["Income Tax", @payroll.income_tax.to_s,@payroll.calculate_year_to_date("income_tax")],
      ["Seguro Social", @payroll.social_security_medicare.to_s, @payroll.calculate_year_to_date("social_security_medicare")],
      ["Medicare", @payroll.medicare.to_s, @payroll.calculate_year_to_date("medicare")],
      ["SINOT", @payroll.sinot.to_s, @payroll.calculate_year_to_date("sinot")],
      ["Plan Médico", @payroll.medical_plan.to_s, @payroll.calculate_year_to_date("medical_plan")],
      ["ASUME", @payroll.asume.to_s, @payroll.calculate_year_to_date("asume")],
      ["Donativos", @payroll.donations.to_s, @payroll.calculate_year_to_date("donations")],
      ["Deducciones", (@payroll.other_deductions_1.to_f + @payroll.other_deductions_2.to_f + @payroll.other_deductions_3.to_f).to_s, @payroll.calculate_year_to_date_deductions.to_s],
      ["Choferil", @payroll.driver_insurance.to_s, @payroll.calculate_year_to_date("driver_insurance")]

    ]

    # Calculate totals
    total_actual = deductions_data.sum { |row| row[1].to_f }
    total_ytd = deductions_data.sum { |row| row[2].to_f }

    deductions_data << ["Total Deducciones", total_actual.round(2), total_ytd.round(2)]

    @pdf.table(
      [["Deducciones", "Actual", "YTD"]] + deductions_data,
      header: true,
      row_colors: [@table_bg_fr1 , @table_bg_fr2],
      position: :center,
      column_widths: { 0 => @document_width/2, 1 => @document_width/4, 2 => @document_width/4 },
      cell_style: { borders: [], size: 9 }
    ) do |table|
      table.row(0).style(
        text_color: @table_header_text,        # Cambia el color del texto a negro
        font_style: :bold,           # Cambia el estilo de fuente a negrita
        size: 10,                    # Cambia el tamaño de la fuente a 12
        background_color:  @table_header_bg  # Cambia el color de fondo
      )

      # Style total row
      total_row_index = deductions_data.size # Last row is the total row
      table.row(total_row_index).style(
        font_style: :bold,
        background_color: @table_sub_total_bg, # Light green background
        text_color: @table_sub_total_text,
        size: 10
      )

    end

    @pdf.move_down 20
    @pdf.text "Pago Bruto: #{@payroll.gross_pay}", size: 10
    @pdf.text "Total Deducciones: #{@payroll.total_deductions}", size: 10
    @pdf.text "Pago Neto: #{@payroll.net_pay}", size: 14, style: :bold, align: :right
  end

  def footer
    # footer section
    @pdf.move_down 50
    @pdf.text "Horas de vacaciones acumuladas #{@payroll.current_acum_vacation_hours.to_f}", align: :left, size: 8
    @pdf.text "Horas de enfermedad acumuldas #{@payroll.current_acum_sickness_hours.to_f}", align: :left, size: 8
  end

  def cloudinary_logo_url(photo_key)
    base_url = "https://res.cloudinary.com/dt7l4axew/image/upload/c_fill,h_250,w_250/f_jpg/v1/"
    environment = Rails.env.production? ? "production" : "development"
    base_url + environment + "/" + photo_key
  end
end
