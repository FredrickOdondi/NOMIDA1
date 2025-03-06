class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
  end

  def terms_and_conditions

  end

  def privacy_policy

  end

  def update_terms_and_conditions
    if current_user.update(terms_accepted: true, privacy_accepted: true)
      flash[:notice] = "Gracias por acceptar los terminos y condiciones y politicas de privacidad"
    else
      flash[:alert] = "Hubo un error al aceptar los terminos y condiciones"
    end
    redirect_to root_path
  end
end
