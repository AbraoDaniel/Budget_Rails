class SessionsController < ApplicationController
  def new
  end

  def create
    # Simulação de busca de usuário. Substitua isso pela sua lógica de autenticação.
    user = User.find_by(email: params[:email])  # Supõe que você tenha uma maneira de verificar o email e a senha
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: 'Você está logado!'
    else
      flash.now[:alert] = 'Email ou senha inválidos'
      render :new
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: 'Você está deslogado!'
  end
end
