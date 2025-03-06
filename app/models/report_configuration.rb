class ReportConfiguration < ApplicationRecord
  belongs_to :company

  validates :report_type, presence: true
  validates :layout, presence: true

  after_initialize :initialize_layout

  def initialize_layout
    self.layout ||= {}
  end

  def layout_2
    layout.transform_values { |v| v.delete_prefix("#") }
  end

  def self.default_layout_for(report_type)
    case report_type
    when "payroll"
      {
        "header_color": "#051245",
        "fields": [
          { "key": "regular_hours", "label": "Regular Hours", "visible": true },
          { "key": "overtime_hours", "label": "Overtime Hours", "visible": true }
        ]
      }
    when "service_payment"
      {
        "header_color": "#123456",
        "fields": [
          { "key": "payment_amount", "label": "Payment Amount", "visible": true }
        ]
      }
    when "hours_report"
      {
        "header_color": "#051245",
        "fields": [
          { "key": "month", "label": "Month", "visible": true },
          { "key": "regular_hours", "label": "Regular Hours", "visible": true },
          { "key": "overtime_hours", "label": "Overtime Hours", "visible": true },
          { "key": "vacation_hours", "label": "Vacation Hours", "visible": true },
          { "key": "sick_hours", "label": "Sick Hours", "visible": true },
          { "key": "total_hours", "label": "Total Hours", "visible": true }
        ]
      }
    when "social_security_medicare"
      {
        "header_color": "#051245",
        "fields": [
          { "key": "month", "label": "Month", "visible": true },
          { "key": "social_security", "label": "Social Security", "visible": true },
          { "key": "medicare", "label": "Medicare", "visible": true },
          { "key": "total", "label": "Total", "visible": true }
        ]
      }
    when "income_tax"
      {
        "header_color": "#051245",
        "fields": [
          { "key": "month", "label": "Month", "visible": true },
          { "key": "income_tax", "label": "Income Tax", "visible": true }
        ]
      }
    when "service_payments_deposits"
      {
        "header_color": "#051245",
        "fields": [
          { "key": "month", "label": "Month", "visible": true },
          { "key": "retention_individuals", "label": "Retention Individuals", "visible": true },
          { "key": "retention_corporations", "label": "Retention Corporations", "visible": true },
          { "key": "total_retention", "label": "Total Retention", "visible": true }
        ]
      }
    else
      {}
    end
  end
end
