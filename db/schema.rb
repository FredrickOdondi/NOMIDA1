# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_01_24_033452) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "companies", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "entity_type"
    t.string "postal_address"
    t.string "postal_city"
    t.string "postal_country"
    t.string "postal_zip_code"
    t.string "physical_address"
    t.string "physical_city"
    t.string "physical_country"
    t.string "physical_zip_code"
    t.boolean "same_as_postal", default: false
    t.string "ein_ss", limit: 9
    t.string "state_employer_number", limit: 10
    t.string "merchant_registration_number", limit: 11
    t.date "start_date"
    t.string "contact_person"
    t.string "contact_phone"
    t.string "contact_email"
    t.string "website"
    t.string "employer"
    t.string "payer"
    t.string "jurisdiction"
    t.string "employment_code"
    t.index ["user_id"], name: "index_companies_on_user_id"
  end

  create_table "contractors", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "first_name"
    t.string "contractor_type"
    t.string "social_security_ein"
    t.string "address_line"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "last_name"
    t.string "city"
    t.string "country"
    t.string "zip_code"
    t.string "email"
    t.index ["company_id"], name: "index_contractors_on_company_id"
  end

  create_table "employees", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "first_name"
    t.string "social_security"
    t.date "birth_date"
    t.date "start_date"
    t.string "phone_number"
    t.decimal "hourly_rate"
    t.string "address_line"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "last_name"
    t.string "employee_number"
    t.string "license_number"
    t.date "termination_date"
    t.boolean "is_driver", default: false
    t.string "city"
    t.string "country"
    t.string "zip_code"
    t.string "last_name_2"
    t.string "middle_name"
    t.string "genre"
    t.string "employ"
    t.string "mobile_phone"
    t.string "status"
    t.string "email"
    t.decimal "fixed_salary"
    t.decimal "initial_acum_vacation_hours"
    t.decimal "initial_acum_sickness_hours"
    t.decimal "current_acum_vacation_hours"
    t.decimal "current_acum_sickness_hours"
    t.index ["company_id"], name: "index_employees_on_company_id"
  end

  create_table "parameters", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "parameter_name"
    t.decimal "parameter_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_parameters_on_company_id"
  end

  create_table "payrolls", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.date "pay_date"
    t.decimal "regular_hours"
    t.decimal "overtime_hours"
    t.decimal "vacation_hours"
    t.decimal "sick_hours"
    t.decimal "gross_pay"
    t.decimal "expense_reimbursement"
    t.decimal "tips"
    t.decimal "other_payments_not_subject_to_retention"
    t.decimal "social_security_medicare"
    t.decimal "driver_insurance"
    t.decimal "income_tax"
    t.decimal "other_deductions_1"
    t.decimal "other_deductions_2"
    t.decimal "total_deductions"
    t.decimal "net_pay"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "fixed_salary"
    t.decimal "other_payments_subject_to_contribution"
    t.decimal "sinot"
    t.decimal "driver_weeks_worked"
    t.integer "index_number"
    t.decimal "commissions"
    t.decimal "bonuses"
    t.decimal "allowances"
    t.decimal "other_payments_subject_to_contribution_2"
    t.decimal "hourly_rate"
    t.decimal "total_salaries"
    t.decimal "medical_plan"
    t.decimal "asume"
    t.decimal "donations"
    t.decimal "other_deductions_3"
    t.decimal "medicare"
    t.string "payment_method"
    t.date "period_start"
    t.date "period_end"
    t.decimal "regular_hours_payment"
    t.decimal "overtime_hours_payment"
    t.decimal "vacation_hours_payment"
    t.decimal "sick_hours_payment"
    t.decimal "current_vacation_hours"
    t.decimal "current_sickness_hours"
    t.decimal "current_acum_vacation_hours"
    t.decimal "current_acum_sickness_hours"
    t.index ["employee_id"], name: "index_payrolls_on_employee_id"
  end

  create_table "report_configurations", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "report_type"
    t.json "layout"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_report_configurations_on_company_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "report_type"
    t.datetime "generated_date", precision: nil
    t.json "filters"
    t.string "file_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_reports_on_company_id"
  end

  create_table "service_payments", force: :cascade do |t|
    t.bigint "contractor_id", null: false
    t.date "payment_date"
    t.decimal "gross_amount"
    t.decimal "deduction_amount"
    t.decimal "net_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "paid_to_individuals_no_retention"
    t.decimal "paid_to_corporation_no_retention"
    t.decimal "paid_to_individuals_with_retention"
    t.decimal "retention_percentage_individuals"
    t.decimal "retention_individuals"
    t.decimal "paid_to_corporation_with_retention"
    t.decimal "retention_percentage_corporations"
    t.decimal "retention_corporations"
    t.decimal "reimbursed_expenses"
    t.decimal "responsibility_payment_health_providers"
    t.decimal "special_contribution_services"
    t.string "payment_method"
    t.date "period_start"
    t.date "period_end"
    t.index ["contractor_id"], name: "index_service_payments_on_contractor_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "last_name_2"
    t.date "birth_date"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.boolean "terms_accepted"
    t.boolean "privacy_accepted"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vacation_sick_accruals", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.date "accrual_date"
    t.decimal "vacation_hours"
    t.decimal "sick_hours"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id"], name: "index_vacation_sick_accruals_on_employee_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "companies", "users"
  add_foreign_key "contractors", "companies"
  add_foreign_key "employees", "companies"
  add_foreign_key "parameters", "companies"
  add_foreign_key "payrolls", "employees"
  add_foreign_key "report_configurations", "companies"
  add_foreign_key "reports", "companies"
  add_foreign_key "service_payments", "contractors"
  add_foreign_key "vacation_sick_accruals", "employees"
end
