class SessionsController < ApplicationController
  def new
    @user = User.new
  end

  def find_user_by_email(email)
    session = NEO4J_DRIVER.session
    query = "MATCH (u:User {email: $email}) RETURN u"
    result = session.run(query, email: email)
    record = result.single  
    session.close
    if record.nil?
      return nil
    else
      node = record[:u]
      user_properties = node.properties.merge(id: node.id)
      return User.new(user_properties)
    end
  end
  
  

  def create
    user = find_user_by_email(params[:email])
    if user.present?
      session[:user_id] = user.id
      redirect_to groups_path, notice: 'Você está logado!'
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
