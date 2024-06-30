require 'time_difference'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :user_signed_in?

  before_action :authenticate_user!

  private

  # Retorna o usuário atual logado com base no user_id armazenado na sessão
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # Verifica se há um usuário logado
  def user_signed_in?
    current_user.present?
  end

  # Redireciona para a página de login se não houver usuário logado
  def authenticate_user!
    unless controller_name == 'splash' && action_name == 'index'
      redirect_to login_path, alert: 'Você precisa estar logado para acessar esta página.' unless user_signed_in?
    end
  end
  
end
