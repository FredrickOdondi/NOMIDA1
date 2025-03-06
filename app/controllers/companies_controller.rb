class CompaniesController < ApplicationController
  before_action :set_company, only: [:show, :edit, :update, :destroy]

  # GET /companies
  def index
    @companies = Company.where(user: current_user)

    if params[:search].present?
      @companies = @companies.where("name ILIKE ?", "%#{params[:search]}%")
    end
    @companies = @companies.page(params[:page]).per(10)
  end

  # GET /companies/1
  def show
  end

  # GET /companies/new
  def new
    @company = Company.new
  end

  # POST /companies
  def create
    @company = Company.new(company_params)
    @company.user = current_user # Asocia la empresa al usuario actual, si tienes autenticación

    if @company.save
      redirect_to @company, notice: 'Company was successfully created.'
    else
      render :new
    end
  end

  # GET /companies/1/edit
  def edit
  end

  # PATCH/PUT /companies/1
  def update
    if @company.update(company_params)
      redirect_to @company, notice: 'Company was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /companies/1
  def destroy
    @company.destroy
    redirect_to companies_url, notice: 'Company was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_company
    @company = Company.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def company_params
    params.require(:company).permit(
      :user_id,
      :name,
      :entity_type,
      :postal_address,
      :postal_city,
      :postal_country,
      :postal_zip_code,
      :physical_address,
      :physical_city,
      :physical_country,
      :physical_zip_code,
      :same_as_postal,
      :ein_ss,
      :state_employer_number,
      :merchant_registration_number,
      :start_date,
      :contact_person,
      :contact_phone,
      :contact_email,
      :website,
      :employer,
      :payer,
      :jurisdiction,
      :employment_code,
      :photo
    )
  end

end
