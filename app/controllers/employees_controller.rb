class EmployeesController < ApplicationController
  def index
    @company = Company.find(params[:company_id])
    @employees = @company.employees

    # Aplicar filtros
    if params[:search].present?
      @employees = @employees.where("CONCAT(first_name, ' ', middle_name, ' ', last_name, ' ', last_name_2 ) ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    end

    @employees = @employees.page(params[:page]).per(10)
  end

  def new
    @company = Company.find(params[:company_id])
    @employee = Employee.new
  end

  def create
    @company = Company.find(params[:company_id])
    @employee = Employee.new(employee_params)
    @employee.company = @company

    if @employee.save
      redirect_to company_employees_path(@company), notice: 'Employee was successfully created.'
    else
      render :new
    end
  end

  def show
    @company = Company.find(params[:company_id])
    @employee = Employee.find(params[:id])
  end

  def edit
    @company = Company.find(params[:company_id])
    @employee = Employee.find(params[:id])
  end

  def update
    @employee = Employee.find(params[:id])
    if @employee.update(employee_params)
      redirect_to company_employees_path(@employee.company), notice: 'Employee was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @employee = Employee.find(params[:id])
    @employee.destroy
    redirect_to company_employees_path(@employee.company), notice: 'Employee was successfully destroyed.'
  end

  private

  def employee_params
    params.require(:employee).permit(
      :first_name, :middle_name, :last_name, :last_name_2, :social_security, :birth_date,
      :start_date, :phone_number, :hourly_rate, :address_line, :employee_number, :license_number,
      :termination_date, :is_driver, :city, :country, :zip_code, :genre, :employ, :mobile_phone,
      :status, :email, :fixed_salary, :photo, :initial_acum_vacation_hours, :initial_acum_sickness_hours
    )
  end

end
