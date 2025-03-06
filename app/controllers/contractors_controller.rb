class ContractorsController < ApplicationController
  before_action :set_contractor, only: [:show, :edit, :update, :destroy]

  # GET /companies/:company_id/contractors
  def index
    @company = Company.find(params[:company_id])
    @contractors = @company.contractors
    if params[:search].present?
      @contractors = @contractors.where("CONCAT(first_name, ' ', last_name) ILIKE ?", "%#{params[:search]}%")
    end
    @contractors = @contractors.page(params[:page]).per(10)
  end

  # GET /companies/:company_id/contractors/:id
  def show
  end

  # GET /companies/:company_id/contractors/new
  def new
    @company = Company.find(params[:company_id])
    @contractor = @company.contractors.build
  end

  def create
    @company = Company.find(params[:company_id])
    @contractor = @company.contractors.build(contractor_params)

    if @contractor.save
      redirect_to company_contractors_path(@company), notice: 'Contractor was successfully created.'
    else
      render :new
    end
  end

  # GET /companies/:company_id/contractors/:id/edit
  def edit
    @company = Company.find(params[:company_id])
    @contractor = @company.contractors.find(params[:id])
  end

  def update
    @contractor = Contractor.find(params[:id])
    if @contractor.update(contractor_params)
      redirect_to company_contractors_path(@contractor.company), notice: 'Contractor was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @contractor.destroy
    redirect_to company_contractors_path(@company), notice: 'Contractor was successfully destroyed.'
  end

  private

  # Encuentra el contratista según el ID de la empresa y el ID del contratista
  def set_contractor
    @company = Company.find(params[:company_id])
    @contractor = @company.contractors.find(params[:id])
  end

  # Permite solo los parámetros necesarios para crear o actualizar un contratista
  def contractor_params
    params.require(:contractor).permit(
      :first_name,
      :last_name,
      :contractor_type,
      :social_security_ein,
      :address_line, :city,
      :country, :zip_code,
      :phone_number,
      :email,
      :company_id)
  end

end
