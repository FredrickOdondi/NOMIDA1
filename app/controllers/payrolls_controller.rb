class PayrollsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_employee, only: [:index, :new, :create]
  before_action :set_payroll, only: [:show, :edit, :update, :destroy]
  before_action :set_sinot_acumulado, only: [:new, :edit]


  def index
    if @employee
      @payrolls = @employee.payrolls
    else
      @payrolls = Payroll.joins(:employee).where(employees: { company_id: @company.id }).includes(:employee)
      if params[:search].present?
        @payrolls = @payrolls.where("CONCAT(employees.first_name, ' ', employees.last_name) ILIKE ?", "%#{params[:search]}%")
      end

      if params[:start_date].present?
        start_date = Date.strptime(params[:start_date])
        @payrolls = @payrolls.where('pay_date >= ?', start_date)
      end

      if params[:end_date].present?
        end_date = Date.strptime(params[:end_date])
        @payrolls = @payrolls.where('pay_date <= ?', end_date)
      end
    end

    @payrolls = @payrolls.order(pay_date: :desc).page(params[:page]).per(10)
  end

  def show
    # @payroll is set by before_action
    respond_to do |format|
      format.html
      format.pdf do
        reporter = PayrollReporter.new(@payroll, @company)
        pdf = reporter.generate
        send_data pdf.render,
                  filename: "payroll_report_#{@payroll.id}.pdf",
                  type: 'application/pdf',
                  disposition: 'attachment'
      end
    end
  end

  def new
    @payroll = Payroll.new

  end

  def create

    @payroll = Payroll.new(payroll_params)

    if @payroll.save
      redirect_to company_payrolls_path(@company), notice: 'Payroll was successfully created.'
    else
      @employees = @company.employees
      render :new
    end
  end

  def edit
    @employees = @company.employees

  end

  def update
    if @payroll.update(payroll_params)
      respond_to do |format|
        format.html { redirect_to company_payrolls_path(@company), notice: 'Payroll was successfully updated.' }
        format.json { render json: { success: true } }
      end
    else
      respond_to do |format|
        format.html do
          @employees = @company.employees
          render :edit
        end
        format.json { render json: { success: false, errors: @payroll.errors.full_messages } }
      end

    end
  end

  def destroy
    @payroll.destroy
    redirect_to company_payrolls_path(@company), notice: 'Payroll was successfully deleted.'
  end

  private

  def set_company
    @company = current_user.companies.find(params[:company_id])
  end

  def set_payroll
    @payroll = Payroll.find(params[:id])
  end

  def set_employee
    @employee = @company.employees.find_by(id: params[:employee_id]) if params[:employee_id]
    @employees = @company.employees
  end

  def set_sinot_acumulado
    @employees = @company.employees
    @sinot_acumulado = @employees.map do |employee|
      # Agrupar los payrolls por año y sumar los valores de SINOT
      employee.payrolls.group_by { |payroll| payroll.pay_date.year }.map do |year, payrolls|
        {
          employee_id: employee.id,
          year: year,
          amount: payrolls.sum { |payroll| payroll.total_salaries.to_f +
            payroll.fixed_salary.to_f +
            payroll.other_payments_subject_to_contribution.to_f +
            payroll.other_payments_subject_to_contribution_2.to_f || 0 }, # Sumar el valor de SINOT por año
          sinotAcum: payrolls.sum { |payroll| payroll.sinot.to_f || 0 }
        }
      end
    end.flatten
  end

  def payroll_params
    params.require(:payroll).permit(
      :employee_id,
      :pay_date,
      :regular_hours,
      :overtime_hours,
      :vacation_hours,
      :sick_hours,
      :gross_pay,
      :expense_reimbursement,
      :tips,
      :other_payments_not_subject_to_retention,
      :social_security_medicare,
      :driver_insurance,
      :income_tax,
      :other_deductions_1,
      :other_deductions_2,
      :total_deductions,
      :net_pay,
      :fixed_salary,
      :other_payments_subject_to_contribution,
      :sinot,
      :driver_weeks_worked,
      :index_number,
      :payment_method,
      :period_start,
      :period_end,
      :hourly_rate,
      :commissions,
      :bonuses,
      :allowances,
      :other_payments_subject_to_contribution_2,
      :total_salaries,
      :medical_plan,
      :asume,
      :donations,
      :other_deductions_3,
      :medicare
    )
  end
end
