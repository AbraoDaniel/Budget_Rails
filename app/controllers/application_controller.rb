class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :user_signed_in?

  def current_user
    return @current_user if @current_user
    @current_user = find_user_by_id(session[:user_id]) if session[:user_id]
  end

  def find_user_by_id(user_id)
    session = NEO4J_DRIVER.session
    query = "MATCH (u:User) WHERE id(u) = $user_id RETURN u"
    result = session.run(query, user_id: user_id)    
    record = result.single
    if record.nil?
      session.close
      return nil  
    end
  
    user_properties = record[:u].properties
    user_properties[:id] = record[:u].id
    
    session.close
    User.new(user_properties)
  end
  
  def user_signed_in?
    current_user.present?
  end

  def authenticate_user!
    redirect_to login_path, alert: 'Você precisa estar logado para acessar esta página.' unless user_signed_in?
  end
end
