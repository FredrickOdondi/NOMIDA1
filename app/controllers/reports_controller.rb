class ReportsController < ApplicationController

  def index
    @company = Company.find(params[:company_id])
    @reports = @company.reports
    if params[:report_type].present?
      @reports = @reports.where("report_type ILIKE ?", "%#{params[:report_type]}%")
    end

    if params[:start_date].present?
      start_date = Date.strptime(params[:start_date])
      @reports = @reports.where('generated_date >= ?', start_date)
    end

    if params[:end_date].present?
      end_date = Date.strptime(params[:end_date])
      @reports = @reports.where('generated_date <= ?', end_date)
    end
    @reports = @reports.order(generated_date: :desc).page(params[:page]).per(10)
  end

  def show
  end


  def new
    @company = Company.find(params[:company_id])
    @report = Report.new
  end

  def create
    @company = Company.find(params[:company_id])
    @report = @company.reports.new(report_params)

    # Extract dynamic filters from params
    filters = {}
    case params[:report][:report_type]
    when 'tipo_1' # Pagos de nómina
      filters[:employee] = params[:report][:filters_employee]
      filters[:start_date] = params[:report][:filters_start_date_1]
      filters[:end_date] = params[:report][:filters_end_date_1]
    when 'tipo_2' # Pagos de servicios prestados
      filters[:contractor] = params[:report][:filters_contractor]
      filters[:start_date] = params[:report][:filters_start_date]
      filters[:end_date] = params[:report][:filters_end_date]
    when 'tipo_3' # Vacaciones y enfermedad acumuladas
      filters[:employee] = params[:report][:filters_employee_2]
    when 'tipo_4' # Hours Report
      filters[:start_date] = params[:report][:filters_start_date_4]
      filters[:end_date] = params[:report][:filters_end_date_4]
    when 'tipo_5' # Social Security and Medicare Deposits Report
      filters[:year] = params[:report][:filters_year_5]
    when 'tipo_6' # Income Tax Deposits Report
      filters[:year] = params[:report][:filters_year_6]
    when 'tipo_7' # Service Payments Deposits Report
      filters[:year] = params[:report][:filters_year_7]
    end

    @report.filters = filters
    @report.generated_date = Time.current

    if @report.save
      redirect_to company_reports_path, notice: 'Reporte creado con éxito.'
    else
      render :new
    end
  end

  def destroy
    @report = Report.find(params[:id])
    @report.destroy
    redirect_to company_reports_path, notice: 'Reporte eliminado'
  end

  def download
    report = Report.find(params[:id])
    # Generar el archivo Excel
    report_file = report.generate_report

    # Enviar el archivo al cliente
    send_data report_file,
               filename: "#{report.type_name}.xlsx",
               type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  end

  private

  def report_params
    params.require(:report).permit(:report_type, :generated_date)
  end
end
