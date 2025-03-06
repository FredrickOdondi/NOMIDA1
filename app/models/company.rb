class Company < ApplicationRecord
  belongs_to :user
  has_many :employees, dependent: :destroy
  has_many :contractors, dependent: :destroy
  has_many :payrolls, through: :employees
  has_many :parameters, dependent: :destroy
  has_many :service_payments, through: :contractors
  has_many :reports, dependent: :destroy
  has_many :report_configurations, dependent: :destroy
  has_one_attached :photo

  validates :name, presence: true

  after_create_commit :create_parameters

  def create_parameters
    parameters.create([
      { parameter_name: "overtime_coefficient", parameter_value: 1.5 },
      { parameter_name: "social_security_medicare", parameter_value: 0.05 },
      { parameter_name: "driver_insurance", parameter_value: 0.05 },
      { parameter_name: "sinot", parameter_value: 1.8 }
    ])
  end
end
