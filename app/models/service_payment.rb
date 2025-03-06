class ServicePayment < ApplicationRecord
  belongs_to :contractor

  validates :payment_date, :contractor_id, presence: true
  # validate :at_least_one_amount_present


  def company
    contractor.company
  end

  def calculate_year_to_date(field_name)
    year_start_date = payment_date.beginning_of_year
    contractor.service_payments.where('payment_date >= ? AND payment_date <= ?', year_start_date, payment_date).sum(field_name)
  end

  def calculate_year_to_date_total_amount
    calculate_year_to_date("amount_a") + calculate_year_to_date("amount_b") + calculate_year_to_date("amount_c")
  end

  private

  def at_least_one_amount_present
    if amount_a.blank? && amount_b.blank? && amount_c.blank?
      errors.add(:base, "At least one amount (amount_a, amount_b, or amount_c) must be present")
    end
  end
end
