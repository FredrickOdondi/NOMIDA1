class ServicePaymentsController < ApplicationController
  before_action :set_company
  before_action :set_contractor, only: [:new]
  def index
    @service_payments = ServicePayment.joins(:contractor).where(contractors: { company_id: @company.id }).includes(:contractor)

    if params[:search].present?
      @service_payments = @service_payments.where("CONCAT(contractors.first_name, ' ', contractors.last_name) ILIKE ?", "%#{params[:search]}%")
    end

    if params[:start_date].present?
      start_date = Date.strptime(params[:start_date])
      @service_payments = @service_payments.where('payment_date >= ?', start_date)
    end

    if params[:end_date].present?
      end_date = Date.strptime(params[:end_date])
      @service_payments = @service_payments.where('payment_date <= ?', end_date)
    end

    @service_payments = @service_payments.order(payment_date: :desc).page(params[:page]).per(10)

  end

  def new
    @contractors = @company.contractors
    @service_payment = ServicePayment.new
  end

  def show
    @service_payment = ServicePayment.find(params[:id])
    @company = current_user.companies.find(params[:company_id])

    respond_to do |format|
      format.html
      format.pdf do
        reporter = ServicePaymentReporter.new(@service_payment, @company)
        pdf = reporter.generate
        send_data pdf.render,
                  filename: "service_payment_report_#{@service_payment.id}.pdf",
                  type: 'application/pdf',
                  disposition: 'attachment'
      end
    end
  end

  def create
    @service_payment = ServicePayment.new(service_payment_params)

    if @service_payment.save
      redirect_to company_service_payments_path(@company), notice: 'Service payment was successfully created.'
    else
      render :new
    end
  end

  def edit
    @contractors = @company.contractors
    @service_payment = ServicePayment.find(params[:id])
    @contractor = @service_payment.contractor
  end


  def update
    @service_payment = ServicePayment.find(params[:id])
    if @service_payment.update(service_payment_params)
      redirect_to company_service_payments_path(@company, @service_payment), notice: 'Payroll was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @service_payment = ServicePayment.find(params[:id])
    @service_payment.destroy
    redirect_to company_service_payments_path(@company), notice: 'Payroll was successfully deleted.'
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_contractor
    @contractor = @company.contractors.find_by(id: params[:contractor_id]) if params[:contractor_id]
  end

  def service_payment_params
    params.require(:service_payment).permit(
      :contractor_id,
      :gross_amount,
      :deduction_amount,
      :net_amount,
      :payment_date,
      :paid_to_individuals_no_retention,
      :paid_to_corporation_no_retention,
      :paid_to_individuals_with_retention,
      :retention_percentage_individuals,
      :retention_individuals,
      :paid_to_corporation_with_retention,
      :retention_percentage_corporations,
      :retention_corporations,
      :reimbursed_expenses,
      :responsibility_payment_health_providers,
      :special_contribution_services,
      :payment_method,
      :period_start,
      :period_end
    )
  end
end
