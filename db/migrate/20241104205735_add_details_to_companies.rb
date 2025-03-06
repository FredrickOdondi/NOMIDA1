class AddDetailsToCompanies < ActiveRecord::Migration[7.1]
  def change
    # Adds columns with specified details
    add_column :companies, :entity_name, :string                    # Nombre de la entidad
    add_column :companies, :entity_type, :string                    # Checkbox or dropdown: Corporación / Individuo
    add_column :companies, :postal_address, :string                 # Dirección Postal
    add_column :companies, :postal_city, :string                    # Ciudad
    add_column :companies, :postal_country, :string                 # País
    add_column :companies, :postal_zip_code, :string                # Zip Code
    add_column :companies, :physical_address, :string               # Dirección Física
    add_column :companies, :physical_city, :string                  # Ciudad
    add_column :companies, :physical_country, :string               # País
    add_column :companies, :physical_zip_code, :string              # Zip Code
    add_column :companies, :same_as_postal, :boolean, default: false # Direccion física igual a la postal
    add_column :companies, :ein_ss, :string, limit: 9               # EIN/SS (9 numbers)
    add_column :companies, :state_employer_number, :string, limit: 10 # Numero patronal estatal (10 numbers)
    add_column :companies, :merchant_registration_number, :string, limit: 11 # Numero de registro de comerciante (11 numbers)
    add_column :companies, :start_date, :date                       # Fecha de comienzo
    add_column :companies, :contact_person, :string                 # Persona de contacto
    add_column :companies, :contact_phone, :string                  # Numero de Telefono
    add_column :companies, :contact_email, :string                  # Email
  end
end
