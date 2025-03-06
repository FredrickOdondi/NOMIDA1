  class Report < ApplicationRecord
    belongs_to :company

    validates :report_type, :filters, presence: true

    def generate_report
      # Generate report
      case report_type
      when 'tipo_1'
        generate_payroll_report # Pagos de nominas
      when 'tipo_2'
        generate_service_payments_report # Pagos de servicios prestados
      when 'tipo_3'
        generate_vacations # Vacaciones y enfermedad acumuladas
      when 'tipo_4'
        generate_hours_report # Hours Report
      when 'tipo_5'
        generate_social_security_medicare_report # Social Security and Medicare Deposits Report
      when 'tipo_6'
        generate_income_tax_report # Income Tax Deposits Report
      when 'tipo_7'
        generate_service_payments_deposits_report # Service Payments Deposits Report
      end
    end

    def type_name
      case report_type
      when 'tipo_1'
        'Pagos de nómina'
      when 'tipo_2'
        'Pagos de servicios prestados'
      when 'tipo_3'
        'Vacaciones y enfermedad acumuladas'
      when 'tipo_4'
        'Informe de horas'
      when 'tipo_5'
        'Informe de depósitos de Seguro Social y Medicare'
      when 'tipo_6'
        'Informe de depósitos de Impuesto sobre Ingresos'
      when 'tipo_7'
        'Informe de depósitos de Pagos por Servicios'
      end
    end

    def filters_formatted
      case report_type
      when 'tipo_1'
        "Empleado: #{filters['employee'] == "all" ? "Todos" : company.employees.find(filters['employee']).full_name}<br>Periodo: #{filters['start_date']} - #{filters['end_date']}".html_safe
      when 'tipo_2'
        "Contratista: #{filters['contractor'] == "all" ? "Todos" : company.contractors.find(filters['contractor']).full_name}<br>Periodo: #{filters['start_date']} - #{filters['end_date']}".html_safe
      when 'tipo_3'
        "Empleado: #{filters['employee'] == "all" ? "Todos" : company.employees.find(filters['employee']).full_name}".html_safe
      when 'tipo_4'
        "Periodo: #{filters['start_date']} - #{filters['end_date']}".html_safe
      when 'tipo_5', 'tipo_6', 'tipo_7'
        "Año: #{filters['year']}".html_safe
      end
    end

    private

    def generate_payroll_report
      package = Axlsx::Package.new
      workbook = package.workbook

      # Iterar sobre empleados y agregar filas con los datos correspondientes
      if filters['employee'] == "all"
      employees = self.company.employees
      else
      employees = self.company.employees.where(id: filters['employee'])
      end

      # Definición de las columnas
      headers = [
        "N°", "Nombres y apellidos completos", "DIRECCIÓN FÍSICA", "CIUDAD, PAÍS Y ZIPCODE",
        "TELÉFONO", "EMAIL", "SEGURO SOCIAL", "HORAS REGULARES ACUMULADAS", "HORAS EXTRAS ACUMULADAS",
        "HORAS DE PAGA POR VACACIONES ACUMULADAS", "HORAS PAGA POR ENFERMEDADES",
        "Paga Regular", "Paga Extra", "Paga por Vacaciones", "Paga por Enfermedad",
        "SUELDO FIJO",
        "Propinas", "Comisiones", "Bonos", "Otros Pagos Sujetos a Contribuciones",
        "Otros Pagos no sujetos a retenciones", "Reembolso de gastos", "Allowances",
        "OTROS PAGOS NO SUJETOS A RETENCIONES", "TOTAL DE INGRESOS",
        "Income Tax", "Seguro Social", "Medicare", "SINOT", "Plan Médico", "ASUME",
        "Donativos", "Deducciones",
        "TOTAL DE DEDUCCIONES"
      ]

      workbook.add_worksheet(name: "Pagos de Nomina") do |sheet|


        # Add the title row with the predefined style
        header = ["Reporte de Nómina", "Periodo:", filters['start_date'], "-", filters['end_date']]
        sheet.add_row header, bg_color: "95AFBA"
        3.times { sheet.add_row }
        sheet.add_row headers

        employees.each_with_index do |employee, index|
          # last_payroll = employee.payrolls.where('pay_date >= ? AND pay_date <= ?', filters['start_date'], filters['end_date']).sum(:regular_hours_payment)
          sheet.add_row [
            index + 1,                        # Número de empleado
            employee.full_name,         # Nombres y apellidos completos
            employee.address_line,           # DIRECCIÓN FÍSICA
            "#{employee.city}, #{employee.country} #{employee.zip_code}", # CIUDAD, PAÍS Y ZIPCODE
            employee.mobile_phone,             # TELÉFONO
            employee.email,             # EMAIL
            employee.social_security || "-",         # SEGURO SOCIAL
            employee.calculate_payroll_sum("regular_hours", filters), # HORAS REGULARES ACUMULADAS
            employee.calculate_payroll_sum("overtime_hours", filters),   # HORAS EXTRAS ACUMULADAS
            employee.calculate_payroll_sum("vacation_hours", filters), # HORAS DE PAGA POR VACACIONES ACUMULADAS
            employee.calculate_payroll_sum("sick_hours", filters),   # HORAS PAGA POR ENFERMEDADES
            employee.calculate_payroll_sum("regular_hours_payment", filters),  # Paga Regular
            employee.calculate_payroll_sum("overtime_hours_payment", filters),    # Paga Extra
            employee.calculate_payroll_sum("vacation_hours_payment", filters), # Paga por Vacaciones
            employee.calculate_payroll_sum("sick_hours_payment", filters),     # Paga por Enfermedad
            employee.calculate_payroll_sum("fixed_salary", filters),
            employee.calculate_payroll_sum("tips", filters),         # Propinas
            employee.calculate_payroll_sum("commissions", filters),  # Comisiones
            employee.calculate_payroll_sum("bonuses", filters),      # Bonos
            employee.calculate_payroll_sum("other_payments_subject_to_contribution", filters),  # Otros Pagos Sujetos a Contribuciones
            employee.calculate_payroll_sum("other_payments_subject_to_contribution_2", filters), # Otros Pagos no sujetos a retenciones
            employee.calculate_payroll_sum("expense_reimbursement", filters), # Reembolso de gastos
            employee.calculate_payroll_sum("allowances", filters),   # Allowances
            employee.calculate_payroll_sum("other_payments_not_subject_to_retention", filters),
            employee.calculate_payroll_sum("gross_pay", filters),
            employee.calculate_payroll_sum("income_tax", filters),   # Income Tax
            employee.calculate_payroll_sum("social_security_medicare", filters), # Seguro Social
            employee.calculate_payroll_sum("medicare", filters),     # Medicare
            employee.calculate_payroll_sum("sinot", filters),        # SINOT
            employee.calculate_payroll_sum("medical_plan", filters),  # Plan Médico
            employee.calculate_payroll_sum("asume", filters),        # ASUME
            employee.calculate_payroll_sum("donations", filters),    # Donativos
            employee.calculate_payroll_sum("other_deductions_1", filters) +  employee&.calculate_payroll_sum("other_deductions_2", filters) + employee&.calculate_payroll_sum("other_deductions_2", filters), # Deducciones
            employee.calculate_payroll_sum("total_deductions", filters)
          ]
        end

        sheet.add_style "A1:E1", b: true, sz: 14, alignment: { horizontal: :center }, bg_color: "95AFBA"
        sheet.add_style "A5:Y5", b: true, sz: 12, alignment: { horizontal: :center }, bg_color: "051245", fg_color: "FFFFFF"
        sheet.add_style "Z5:AH5", b: true, sz: 12, alignment: { horizontal: :center }, bg_color: "00B0F0", fg_color: "FFFFFF"
      end

      workbook.add_worksheet(name: "Reporte de nominas detallado") do |sheet|
        sheet.add_row headers.map { |head_word| head_word.sub(" ACUMULADAS", "") } << "FECHA DE PAGO"
        row_number = 1
        employees.each do |employee|
          employee.payrolls.each do |payroll|
            sheet.add_row [
              row_number,
              employee.full_name,
              employee.address_line,           # DIRECCIÓN FÍSICA
              "#{employee.city}, #{employee.country} #{employee.zip_code}", # CIUDAD, PAÍS Y ZIPCODE
              employee.mobile_phone,             # TELÉFONO
              employee.email,
              employee.social_security || "-",         # SEGURO SOCIAL
              payroll.regular_hours || 0,
              payroll.overtime_hours || 0,
              payroll.vacation_hours || 0,
              payroll.sick_hours || 0,
              payroll.regular_hours_payment || 0,
              payroll.overtime_hours_payment || 0,
              payroll.vacation_hours_payment || 0,
              payroll.sick_hours_payment || 0,
              payroll.fixed_salary || 0,
              payroll.tips || 0,
              payroll.commissions || 0,
              payroll.bonuses || 0,
              payroll.other_payments_subject_to_contribution || 0,
              payroll.other_payments_not_subject_to_retention || 0,
              payroll.expense_reimbursement || 0,
              payroll.allowances || 0,
              payroll.other_payments_not_subject_to_retention || 0,
              payroll.gross_pay || 0,
              payroll.income_tax || 0,
              payroll.social_security_medicare || 0,
              payroll.medicare || 0,
              payroll.sinot || 0,
              payroll.medical_plan || 0,
              payroll.asume || 0,
              payroll.donations || 0,
              [payroll.other_deductions_1, payroll.other_deductions_2, payroll.other_deductions_3].compact.sum(&:to_f),
              payroll.total_deductions || 0,
              payroll.pay_date || "-",
            ]
            row_number += 1
          end
        end
      end

      # Devuelve el contenido del archivo
      package.to_stream.read
    end

    def generate_service_payments_report
      package = Axlsx::Package.new
      workbook = package.workbook

      # Iterar sobre empleados y agregar filas con los datos correspondientes
      if filters['contractor'] == "all"
        contractors = self.company.contractors
      else
        contractors = self.company.contractors.where(id: filters['contractor'])
      end

      # Definición de las columnas
      headers = [
        "N°",
        "CONTRATISTA",
        "DIRECCIÓN FÍSICA",
        "CIUDAD, PAÍS Y ZIPCODE",
        "TELÉFONO",
        "EMAIL",
        "SEGURO SOCIAL (EIN)",
        "Pagos a individuales no sujetos a retención",
        "Pago a corporaciones no sujetas a retención",
        "Pago a individuales sujetos a retención",
        "Retención a individuales",
        "Pago a corporaciones sujetas a retención",
        "Retención a coporaciones",
        "Gastos Reembolsados",
        "Responsabilidad de pago a proveedores de salud",
        "Aportación especial por Servicio Profesionales y Consultivos bajo la Ley 48-2013",
        "Monto Bruto",
        "Monto de Deducción",
        "Monto Neto"
      ]

      workbook.add_worksheet(name: "Service Payments Report") do |sheet|

        # Agregar los encabezados
        sheet.add_row headers

        contractors.each_with_index do |contractor, index|
          sheet.add_row [
            index + 1, # Número de empleado
            contractor.full_name, # Nombres y apellidos completos
            contractor.address_line, # DIRECCIÓN FÍSICA
            contractor.city, # CIUDAD, PAÍS Y ZIPCODE
            contractor.country, # TELÉFONO
            contractor.zip_code, # EMAIL
            contractor.social_security_ein, # SEGURO SOCIAL (EIN)
            contractor.calculate_service_payment_sum("paid_to_individuals_no_retention", filters),
            contractor.calculate_service_payment_sum("paid_to_corporation_no_retention", filters),
            contractor.calculate_service_payment_sum("paid_to_individuals_with_retention", filters),
            contractor.calculate_service_payment_sum("retention_individuals", filters),
            contractor.calculate_service_payment_sum("paid_to_corporation_with_retention", filters),
            contractor.calculate_service_payment_sum("retention_corporations", filters),
            contractor.calculate_service_payment_sum("reimbursed_expenses", filters),
            contractor.calculate_service_payment_sum("responsibility_payment_health_providers", filters),
            contractor.calculate_service_payment_sum("special_contribution_services", filters),
            contractor.calculate_service_payment_sum("gross_amount", filters),
            contractor.calculate_service_payment_sum("deduction_amount", filters),
            contractor.calculate_service_payment_sum("net_amount", filters)
          ]
        end
      end

      workbook.add_worksheet(name: "Service Payments Report Detail") do |sheet|

        new_headers = ["Fecha de Pago", "Inicio Periodo de Pago", "Fin Periodo de Pago"]
        sheet.add_row headers.insert(7, *new_headers)
        row_number = 1

        contractors.each do |contractor|
          contractor.service_payments.order(payment_date: :asc).each do |service_payment|
            sheet.add_row [
              row_number, # Número de empleado
              contractor.full_name, # Nombres y apellidos completos
              contractor.address_line, # DIRECCIÓN FÍSICA
              contractor.city, # CIUDAD, PAÍS Y ZIPCODE
              contractor.country, # TELÉFONO
              contractor.zip_code, # EMAIL
              contractor.social_security_ein, # SEGURO SOCIAL (EIN)
              service_payment.payment_date,
              service_payment.period_start || "-",
              service_payment.period_end || "-",
              service_payment.paid_to_individuals_no_retention.to_f,
              service_payment.paid_to_corporation_no_retention.to_f,
              service_payment.paid_to_individuals_with_retention.to_f,
              service_payment.retention_individuals.to_f,
              service_payment.paid_to_corporation_with_retention.to_f,
              service_payment.retention_corporations.to_f,
              service_payment.reimbursed_expenses.to_f,
              service_payment.responsibility_payment_health_providers.to_f,
              service_payment.special_contribution_services.to_f,
              service_payment.gross_amount.to_f,
              service_payment.deduction_amount.to_f,
              service_payment.net_amount.to_f
            ]

            row_number += 1
          end
        end
      end

      # Devuelve el contenido del archivo
      package.to_stream.read
    end
    def generate_vacations
      package = Axlsx::Package.new
      workbook = package.workbook

      if filters['employee'] == "all"
        employees = self.company.employees
      else
        employees = self.company.employees.where(id: filters['employee'])
      end

      workbook.add_worksheet(name: "Vacations Report") do |sheet|
        headers = ["N°", "Nombres y apellidos completos", "DIRECCIÓN FÍSICA", "CIUDAD, PAÍS Y ZIPCODE",
                  "TELÉFONO", "SEGURO SOCIAL", "FECHA DE INICIO", "FECHA DE FIN", "HORAS DE VACACIONES ACUMULADAS", "HORAS ENFERMEDAD ACUMULADA"]
        sheet.add_row headers

        employees.each_with_index do |employee, index|
          sheet.add_row [
            index + 1,
            employee.full_name,
            employee.address_line || "-",
            "#{employee.city || '-'}, #{employee.country || '-'} #{employee.zip_code || '-'}",
            employee.mobile_phone || "-",
            employee.social_security || "-",
            employee.start_date || "-",
            employee.termination_date || "-",
            employee.current_acum_vacation_hours || 0,
            employee.current_acum_sickness_hours || 0
          ]
        end
      end

      workbook.add_worksheet(name: "Vacations Report Detail") do |sheet|
        sheet.add_row ["N°", "Nombres y apellidos completos",  "SEGURO SOCIAL", "FECHA DE PAGO",
                  "CURRENT ACUM VACATION HOURS", "CURRENT ACUM SICKNESS HOURS",
                   "CURRENT VACATION HOURS", "CURRENT SICKNESS HOURS",
                  "REGULAR HOURS", "OVERTIME HOURS", "VACATION HOURS", "SICK HOURS"]

        row_number = 1

        employees.order(last_name: :asc).each do |employee|
          employee.update_vations_reports # in evaluations if is efficient
          # binding.pry
          employee.payrolls.order(pay_date: :asc).each do |payroll|
            sheet.add_row [
              row_number,
              employee.full_name,
              employee.social_security || "-",
              payroll.pay_date || "-",
              payroll.current_acum_vacation_hours || 0,
              payroll.current_acum_sickness_hours || 0,
              payroll.current_vacation_hours || 0,
              payroll.current_sickness_hours || 0,
              payroll.regular_hours || 0,
              payroll.overtime_hours || 0,
              payroll.vacation_hours || 0,
              payroll.sick_hours || 0
            ]

            row_number += 1
          end
        end
      end
      package.to_stream.read
    end

    def generate_hours_report
      package = Axlsx::Package.new
      workbook = package.workbook

      workbook.add_worksheet(name: "Hours Report") do |sheet|
        # Add headers
        headers = ["Month", "Regular Hours", "Overtime Hours", "Vacation Hours", "Sick Hours", "Total Hours"]
        sheet.add_row ["Hours Report", "Period:", filters['start_date'], "-", filters['end_date']], bg_color: "95AFBA"
        2.times { sheet.add_row }
        sheet.add_row headers

        # Get all payrolls within the date range
        payrolls = company.payrolls.where('pay_date >= ? AND pay_date <= ?', filters['start_date'], filters['end_date'])

        # Group by month and calculate totals
        payrolls.group_by { |p| p.pay_date.beginning_of_month }.each do |month, month_payrolls|
          sheet.add_row [
            month.strftime("%B %Y"),
            month_payrolls.sum(&:regular_hours) || 0,
            month_payrolls.sum(&:overtime_hours) || 0,
            month_payrolls.sum(&:vacation_hours) || 0,
            month_payrolls.sum(&:sick_hours) || 0,
            month_payrolls.sum { |p| (p.regular_hours || 0) + (p.overtime_hours || 0) + (p.vacation_hours || 0) + (p.sick_hours || 0) }
          ]
        end

        # Add styles
        sheet.add_style "A1:E1", b: true, sz: 14, alignment: { horizontal: :center }, bg_color: "95AFBA"
        sheet.add_style "A4:F4", b: true, sz: 12, alignment: { horizontal: :center }, bg_color: "051245", fg_color: "FFFFFF"
      end

      package.to_stream.read
    end

    def generate_social_security_medicare_report
      package = Axlsx::Package.new
      workbook = package.workbook

      workbook.add_worksheet(name: "Social Security and Medicare") do |sheet|
        # Add headers
        headers = ["Month", "Social Security", "Medicare", "Total"]
        sheet.add_row ["Social Security and Medicare Deposits Report", "Year:", filters['year']], bg_color: "95AFBA"
        2.times { sheet.add_row }
        sheet.add_row headers

        # Generate rows for each month
        (1..12).each do |month|
          start_date = Date.new(filters['year'].to_i, month, 1)
          end_date = start_date.end_of_month

          payrolls = company.payrolls.where('pay_date >= ? AND pay_date <= ?', start_date, end_date)
          
          social_security = payrolls.sum(&:social_security_medicare) || 0
          medicare = payrolls.sum(&:medicare) || 0

          sheet.add_row [
            start_date.strftime("%B"),
            social_security,
            medicare,
            social_security + medicare
          ]
        end

        # Add styles
        sheet.add_style "A1:B1", b: true, sz: 14, alignment: { horizontal: :center }, bg_color: "95AFBA"
        sheet.add_style "A4:D4", b: true, sz: 12, alignment: { horizontal: :center }, bg_color: "051245", fg_color: "FFFFFF"
      end

      package.to_stream.read
    end

    def generate_income_tax_report
      package = Axlsx::Package.new
      workbook = package.workbook

      workbook.add_worksheet(name: "Income Tax") do |sheet|
        # Add headers
        headers = ["Month", "Income Tax Withheld", "Total"]
        sheet.add_row ["Income Tax Deposits Report", "Year:", filters['year']], bg_color: "95AFBA"
        2.times { sheet.add_row }
        sheet.add_row headers

        # Generate rows for each month
        (1..12).each do |month|
          start_date = Date.new(filters['year'].to_i, month, 1)
          end_date = start_date.end_of_month

          payrolls = company.payrolls.where('pay_date >= ? AND pay_date <= ?', start_date, end_date)
          income_tax = payrolls.sum(&:income_tax) || 0

          sheet.add_row [
            start_date.strftime("%B"),
            income_tax,
            income_tax
          ]
        end

        # Add styles
        sheet.add_style "A1:B1", b: true, sz: 14, alignment: { horizontal: :center }, bg_color: "95AFBA"
        sheet.add_style "A4:C4", b: true, sz: 12, alignment: { horizontal: :center }, bg_color: "051245", fg_color: "FFFFFF"
      end

      package.to_stream.read
    end

    def generate_service_payments_deposits_report
      package = Axlsx::Package.new
      workbook = package.workbook

      workbook.add_worksheet(name: "Service Payments Deposits") do |sheet|
        # Add headers
        headers = ["Month", "Retention Individuals", "Retention Corporations", "Total Withholding"]
        sheet.add_row ["Service Payments Deposits Report", "Year:", filters['year']], bg_color: "95AFBA"
        2.times { sheet.add_row }
        sheet.add_row headers

        # Generate rows for each month
        (1..12).each do |month|
          start_date = Date.new(filters['year'].to_i, month, 1)
          end_date = start_date.end_of_month

          service_payments = company.service_payments.where('payment_date >= ? AND payment_date <= ?', start_date, end_date)
          
          retention_individuals = service_payments.sum(&:retention_individuals) || 0
          retention_corporations = service_payments.sum(&:retention_corporations) || 0

          sheet.add_row [
            start_date.strftime("%B"),
            retention_individuals,
            retention_corporations,
            retention_individuals + retention_corporations
          ]
        end

        # Add styles
        sheet.add_style "A1:B1", b: true, sz: 14, alignment: { horizontal: :center }, bg_color: "95AFBA"
        sheet.add_style "A4:D4", b: true, sz: 12, alignment: { horizontal: :center }, bg_color: "051245", fg_color: "FFFFFF"
      end

      package.to_stream.read
    end

    def define_styles(workbook)
      styles = workbook.styles
      {
        title: styles.add_style(sz: 16, b: true, alignment: { horizontal: :center }, fg_color: "FFFFFF", bg_color: "0000FF"),
        header: styles.add_style(sz: 14, b: true, alignment: { horizontal: :center }, fg_color: "FFFFFF", bg_color: "051245"),
        data: styles.add_style(sz: 12, alignment: { horizontal: :left })
      }
    end
  end
