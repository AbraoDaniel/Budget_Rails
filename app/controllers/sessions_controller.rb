class SessionsController < ApplicationController
  def new
    @user = User.new
  end

  def find_user_by_email(email)
    session = NEO4J_DRIVER.session
    query = "MATCH (u:User {email: $email}) RETURN u"
    result = session.run(query, email: email)
    record = result.single  # Pega o primeiro registro do resultado, se houver
    session.close
    if record.nil?
      # Não há registros, trata de acordo
      return nil
    else
      # Há um registro, vamos construir um objeto usuário a partir dele
      node = record[:u]
      user_properties = node.properties.merge(id: node.id)
      return User.new(user_properties)
    end
  end
  
  

  def create
    # Simulação de busca de usuário. Substitua isso pela sua lógica de autenticação.
    user = find_user_by_email(params[:email])
    # MATCH (u:User {email: 'email@example.com'})
    # RETURN u
    if user.present?
      session[:user_id] = user.id
      redirect_to groups_path, notice: 'Você está logado!'
    else
      flash.now[:alert] = 'Email ou senha inválidos'
      render :new
    end
  end

  # def destroy
  #   reset_session  # Limpa a sessão
  #   redirect_to root_path, notice: 'Você saiu com sucesso.'
  # end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: 'Você está deslogado!'
  end
end
