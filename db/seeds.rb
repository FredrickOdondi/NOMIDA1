# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'faker'

user = User.create(
  email: "cboloc@uni.pe",
  password: "123456",
  password_confirmation: "123456"
)

user = User.find_by(email: "cboloc@uni.pe")
puts user.present? ? "User created successfully" : "User creation failed"

Company.destroy_all # Clean up the database

5.times do
  company = Company.create(
    user_id: user.id, # Assumes you have existing users
    name: Faker::Company.name,
    entity_type: ["Corporation", "LLC", "Partnership", "Sole Proprietorship"].sample,
    postal_address: Faker::Address.street_address,
    postal_city: Faker::Address.city,
    postal_country: Faker::Address.country,
    postal_zip_code: Faker::Address.zip_code,
    physical_address: Faker::Address.street_address,
    physical_city: Faker::Address.city,
    physical_country: Faker::Address.country,
    physical_zip_code: Faker::Address.zip_code,
    same_as_postal: [true, false].sample,
    ein_ss: Faker::Number.number(digits: 9),
    state_employer_number: Faker::Number.number(digits: 10),
    merchant_registration_number: Faker::Number.number(digits: 11),
    start_date: Faker::Date.between(from: '2000-01-01', to: Date.today),
    contact_person: Faker::Name.name,
    contact_phone: Faker::PhoneNumber.phone_number,
    contact_email: Faker::Internet.email,
    website: Faker::Internet.domain_name,
    employer: Faker::Company.name,
    payer: Faker::Company.name,
    jurisdiction: Faker::Address.state,
    employment_code: Faker::Alphanumeric.alphanumeric(number: 6).upcase
  )

  puts "Company created successfully" if company.present?

  10.times do
    employee = Employee.create(
      company_id: company.id,
      first_name: Faker::Name.first_name,
      middle_name: Faker::Name.middle_name,
      last_name: Faker::Name.last_name,
      last_name_2: Faker::Name.last_name,
      social_security: Faker::Number.number(digits: 9),
      birth_date: Faker::Date.birthday(min_age: 18, max_age: 65),
      start_date: Faker::Date.backward(days: 1000),
      phone_number: Faker::PhoneNumber.phone_number,
      mobile_phone: Faker::PhoneNumber.cell_phone,
      hourly_rate: Faker::Number.decimal(l_digits: 2, r_digits: 2),
      address_line: Faker::Address.street_address,
      city: Faker::Address.city,
      country: Faker::Address.country,
      zip_code: Faker::Address.zip_code,
      employee_number: Faker::Number.number(digits: 6),
      license_number: Faker::Alphanumeric.alphanumeric(number: 8).upcase,
      termination_date: [nil, Faker::Date.backward(days: 100)].sample, # Sometimes terminated
      is_driver: [true, false].sample,
      genre: ["Masculino", "Femenino"].sample,
      employ: Faker::Job.title,
      status: ["Activo", "Inactivo"].sample,
      email: Faker::Internet.email
    )

    puts "Employee created successfully" if employee.present?



    

  end

  10.times do
    contractor = Contractor.create(
      company_id: company.id,
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      contractor_type: ["Corporación", "Individuo"].sample,
      social_security_ein: Faker::Number.number(digits: 9),
      address_line: Faker::Address.street_address,
      city: Faker::Address.city,
      country: Faker::Address.country,
      zip_code: Faker::Address.zip_code,
      phone_number: Faker::PhoneNumber.phone_number
    )

    puts "Contractor created successfully" if contractor.present?
  end
end
