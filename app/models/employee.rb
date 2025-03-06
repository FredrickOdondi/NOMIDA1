class Employee < ApplicationRecord
  belongs_to :company
  has_many :payrolls, dependent: :destroy
  has_one_attached :photo

  validates :first_name, :last_name, :social_security, :start_date, presence: true

  def full_name
    [first_name, middle_name, last_name, last_name_2].compact.join(' ')
  end

  def yearly_earnings_up_to(year)
    payrolls.where('extract(year from pay_date) = ?', year).sum(:gross_salary) || 0
  end

  def calculate_payroll_sum(field, filters)
    payrolls
      .where('pay_date >= ? AND pay_date <= ?', filters['start_date'], filters['end_date'])
      .sum(field) || 0
  end

  def update_vations_reports
    payrolls.order(pay_date: :asc).each do |payroll|
      payroll.update_current_acum_vacation_hours
      payroll.save!
    end
  end

  def payrolls_created_in_order?
    sorted_payrolls = payrolls.order(created_at: :asc)

    sorted_payrolls.each_cons(2) do |payroll1, payroll2|
      return false unless payroll2.created_at > payroll1.created_at && payroll2.pay_date > payroll1.pay_date
    end

    true
  end
end
