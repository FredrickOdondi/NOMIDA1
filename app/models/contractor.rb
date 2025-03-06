class Contractor < ApplicationRecord
  belongs_to :company
  has_many :service_payments, dependent: :destroy

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def calculate_service_payment_sum(field, filters)
    service_payments
      .where('payment_date >= ? AND payment_date <= ?', filters['start_date'], filters['end_date'])
      .sum(field) || 0
  end
end
