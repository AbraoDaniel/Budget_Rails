class SplashController < ApplicationController
  # Remova skip_before_action se não estiver mais usando uma verificação de autenticação aqui
  # skip_before_action :authenticate_user!

  def index
    # Aqui, substitua `user_signed_in?` por sua própria verificação de autenticação
    if user_signed_in?
      render :index
    else
      render :index
    end
  end

  private

  # Implemente sua própria verificação de autenticação baseada em sessão ou outro método
  def user_signed_in?
    # Isto é apenas um placeholder. Você precisa implementar a lógica real baseada em como você está gerenciando a autenticação.
    session[:user_id].present?
  end
end
