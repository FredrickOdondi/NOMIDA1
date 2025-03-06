class ReportConfigurationsController < ApplicationController
  before_action :set_company
  before_action :set_report_configuration, only: [:edit, :update, :destroy]

  def index
    @report_configurations = @company.report_configurations
  end

  def new
    # Initialize a new report config with an empty layout so we don't get nil errors in the form
    @report_configuration = @company.report_configurations.new(layout: {})
  end

  def create
    @report_configuration = @company.report_configurations.new(report_configuration_params)
    merge_color_fields_into_layout(@report_configuration)

    if @report_configuration.save
      redirect_to company_report_configurations_path(@company), notice: 'Report configuration created successfully.'
    else
      flash.now[:alert] = 'There was an error creating the report configuration.'
      render :new
    end
  end

  def edit
    # @report_configuration is set by set_report_configuration
  end

  def update
    @report_configuration.assign_attributes(report_configuration_params)
    merge_color_fields_into_layout(@report_configuration)

    if @report_configuration.save
      redirect_to company_report_configurations_path(@company), notice: 'Report configuration updated successfully.'
    else
      flash.now[:alert] = 'There was an error updating the report configuration.'
      render :edit
    end
  end

  def destroy
    @report_configuration.destroy
    redirect_to company_report_configurations_path(@company), notice: 'Report configuration deleted.'
  end

  private

  def set_company
    # Adjust based on your current_user logic or however you find the company
    @company = Company.find(params[:company_id])
  end

  def set_report_configuration
    @report_configuration = @company.report_configurations.find(params[:id])
  end

  # Strong params for non-JSON fields
  def report_configuration_params
    params.require(:report_configuration).permit(:report_type)
  end

  # Merge color fields from the form into the layout JSON
  def merge_color_fields_into_layout(report_config)
    # color_field_tag fields come in at the top-level of params
    layout_params = {
      'header_background' => params[:head],
      'header_text_color' => params[:head_text],
      'table_header_background' => params[:table_h_bg_fr],
      'table_header_text_c' => params[:table_h_text_c],
      'table_background_1' => params[:table_bg_fr1],
      'table_text_color1' => params[:table_text_c1],
      'table_background_2' => params[:table_bg_fr2],
      'table_text_color2'   => params[:table_text_c2],
      'table_subtotal_background_2' => params[:table_st_bg_fr2],
      'table_subtotal_text_color2' => params[:table_st_text_c2]
    }

    # Remove any keys that are nil or blank to avoid overwriting values with empty strings
    layout_params.compact_blank! if layout_params.respond_to?(:compact_blank!)

    # Merge them into the existing layout (or a blank hash if nil)
    report_config.layout = (report_config.layout || {}).merge(layout_params)
  end
end
