class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :user_signed_in?

  def current_user
    return @current_user if @current_user
    @current_user = find_user_by_id(session[:user_id]) if session[:user_id]
  end

  def find_user_by_id(user_id)
    session = NEO4J_DRIVER.session
    # Certifique-se de que você está usando o atributo correto para o ID. 
    # Este exemplo pressupõe que você tem um atributo `uuid` para os IDs de usuário:
    query = "MATCH (u:User) WHERE id(u) = $user_id RETURN u"
    result = session.run(query, user_id: user_id)    
    # Verificar se há algum resultado
    record = result.single
    if record.nil?
      session.close
      return nil  # Retorna nil se nenhum usuário for encontrado
    end
  
    # Extrair propriedades do usuário e criar uma nova instância do modelo User
    user_properties = record[:u].properties
    user_properties[:id] = record[:u].id  # Inclui o ID interno se necessário
    
    session.close
    User.new(user_properties)
  end
  

  # before_action :authenticate_user!

  # Retorna o usuário atual logado com base no user_id armazenado na sessão
  # def current_user
  #   raise User.all.inspect
  #   raise session[:user_id].inspect
  #   # @current_user 
  #   @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  # end

  # # Verifica se há um usuário logado
  def user_signed_in?
    current_user.present?
  end

  # # Redireciona para a página de login se não houver usuário logado
  def authenticate_user!
    redirect_to login_path, alert: 'Você precisa estar logado para acessar esta página.' unless user_signed_in?
  end
end
