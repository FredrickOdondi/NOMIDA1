class ParametersController < ApplicationController
  def index
    @company = Company.find(params[:company_id])
    @parameters = Parameter.where(company: @company)
  end

  def new
    @company = Company.find(params[:company_id])
    @parameter = Parameter.new(company: @company)
  end

  def create
    @parameter = Parameter.new(parameters_params)
    if @parameter.save
      redirect_to company_parameters_path(@parameter.company), notice: 'Parameter has successfully created'
    else
      render :new
    end
  end

  def edit
    @parameter = Parameter.find(params[:id])
    @company = @parameter.company
  end

  def destroy
    @parameter = Parameter.find(params[:id])
    if @parameter.destroy
      redirect_to company_parameters_path(@parameter.company), notice: 'Parameter has successfully deleted'
    else
      redirect_to company_parameters_path(@parameter.company), alert: 'Parameter has not been deleted'
    end
  end

  private

  def parameters_params
    params.require(:parameter).permit(
      :parameter_name,
      :parameter_value,
      :company_id
    )
  end
end
