class Payroll < ApplicationRecord
  belongs_to :employee

  before_save :calculate_totals
  before_save :update_current_acum_vacation_hours

  # Validations
  validates :employee_id, :pay_date, presence: true

  def salary
    (overtime_hours.to_f * employee.hourly_rate.to_f * 1.5) + (regular_hours.to_f * employee.hourly_rate.to_f)  +
     (vacation_hours.to_f * employee.hourly_rate.to_f)
     (sick_hours.to_f * employee.hourly_rate.to_f)
  end

  def calculate_year_to_date(field_name)
    year_start_date = pay_date.beginning_of_year
    employee.payrolls.where('pay_date >= ? AND pay_date <= ?', year_start_date, pay_date).sum(field_name)
  end

  def calculate_year_to_date_deductions
    calculate_year_to_date("other_deductions_1") + calculate_year_to_date("other_deductions_2") + calculate_year_to_date("other_deductions_3")
  end

  def update_current_acum_vacation_hours
    # binding.pry
    # sum hours worked in the current month
    self.current_vacation_hours = 0
    self.current_sickness_hours = 0

    current_month_payrolls = employee.payrolls.where('pay_date >= ? AND pay_date <= ?', pay_date.beginning_of_month, pay_date.end_of_month)

    # there is any acumulated hours in the current month?
    has_vacations_acumulated_hours = current_month_payrolls.sum(:current_vacation_hours)
    has_sickness_acumulated_hours = current_month_payrolls.sum(:current_sickness_hours)
    # when the employee start to work?

    payrolls_until_now = employee.payrolls.where('pay_date <= ?', pay_date)

    current_acum_sickness_hours = employee.initial_acum_sickness_hours.to_f + payrolls_until_now.sum(:current_sickness_hours) - payrolls_until_now.sum(:sick_hours)
    current_acum_vacation_hours = employee.initial_acum_vacation_hours.to_f + payrolls_until_now.sum(:current_vacation_hours) - payrolls_until_now.sum(:vacation_hours)

    if new_record?
      current_acum_sickness_hours = current_acum_sickness_hours - sick_hours.to_f
      current_acum_vacation_hours = current_acum_vacation_hours - vacation_hours.to_f
    end

    if has_vacations_acumulated_hours.positive? || has_sickness_acumulated_hours.positive?
      self.current_acum_vacation_hours = current_acum_vacation_hours
      self.current_acum_sickness_hours = current_acum_sickness_hours
      employee.current_acum_vacation_hours = current_acum_vacation_hours
      employee.current_acum_sickness_hours = current_acum_sickness_hours
      employee.save

      return
    end

    days_of_service = (pay_date - employee.start_date).to_i

    hours_worked = current_month_payrolls.sum(:regular_hours).to_f +
                   current_month_payrolls.sum(:overtime_hours).to_f +
                   current_month_payrolls.sum(:vacation_hours).to_f +
                   current_month_payrolls.sum(:sick_hours).to_f

    if new_record?
      hours_worked = hours_worked + regular_hours.to_f + overtime_hours.to_f + vacation_hours.to_f + sick_hours.to_f
    end

    if employee.start_date < Date.new(2017, 1, 26) # before 2017/01/26
      self.current_vacation_hours = 10 if hours_worked >= 115
      self.current_sickness_hours = 8 if hours_worked >= 115 && current_acum_sickness_hours <= 120

    elsif days_of_service < 365 # less than a year
      self.current_vacation_hours = 4 if hours_worked >= 130
      self.current_sickness_hours = 8 if hours_worked >= 130 && current_acum_sickness_hours <= 120

    elsif days_of_service < 365*5 # less than 5 years
      self.current_vacation_hours = 6 if hours_worked >= 130
      self.current_sickness_hours = 8 if hours_worked >= 130 && current_acum_sickness_hours <= 120
    elsif days_of_service < 15*365 # less than 15 years
      self.current_vacation_hours = 8  if hours_worked >= 130
      self.current_sickness_hours = 8 if hours_worked >= 130 && current_acum_sickness_hours <= 120
    else # more than 15 years
      self.current_vacation_hours = 10 if hours_worked >= 130
      self.current_sickness_hours = 8 if hours_worked >= 130 && current_acum_sickness_hours <= 120
    end

    self.current_acum_vacation_hours = self.current_vacation_hours + current_acum_vacation_hours
    self.current_acum_sickness_hours = self.current_sickness_hours + current_acum_sickness_hours
    employee.current_acum_vacation_hours = self.current_acum_vacation_hours
    employee.current_acum_sickness_hours = self.current_acum_sickness_hours
    employee.save
  end

  private

  def calculate_totals
    self.regular_hours_payment = regular_hours.to_f * hourly_rate.to_f
    self.overtime_hours_payment = overtime_hours.to_f * hourly_rate.to_f * 1.5
    self.vacation_hours_payment = vacation_hours.to_f * hourly_rate.to_f
    self.sick_hours_payment = sick_hours.to_f * hourly_rate.to_f
  end
end
