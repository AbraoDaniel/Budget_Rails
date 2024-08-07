class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]

  def index
    @users = User.all
  end

  def show
  end

  def new
    raise 'aqui'.inspect
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, notice: 'User was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update_user
    @user = User.find(params[:id].to_i)
    if @user
      session = NEO4J_DRIVER.session
      begin
        if params[:user]['password'].present? && params[:user]['password_confirmation'].present? && params[:user]['password'] == params[:user]['password_confirmation']
          session.run("MATCH (u:User) WHERE id(u) = $id SET u += {name: $name, email: $email, encrypted_password: $encrypted_password}",
                      id: @user.id,
                      name: params[:user]['name'],
                      email: params[:user]['email'],
                      encrypted_password: params[:user]['password'])
        else
          session.run("MATCH (u:User) WHERE id(u) = $id SET u += {name: $name, email: $email}",
                      id: @user.id,
                      name: params[:user]['name'],
                      email: params[:user]['email'])
        end
        flash[:notice] = 'User was successfully updated.'
        redirect_to @user
      rescue => e
        flash[:alert] = "Failed to update user: #{e.message}"
        render :edit
      ensure
        session.close
      end
    else
      flash[:alert] = "User not found."
      redirect_to users_url
    end
  end
  
  def update
    if params[:user]['password'].present? && params[:user]['password_confirmation'].present? && params[:user]['password'] == params[:user]['password_confirmation']
      if @user.update(user_params)
        redirect_to @user, notice: 'User was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    else
      if @user.update(name: params[:user]['name'], email: params[:user]['email'])
        redirect_to @user, notice: 'User was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @user = User.find(params[:id].to_i)
    session = NEO4J_DRIVER.session
    begin
      delete_operations_query = """
        MATCH (u:User)-[:HAS_GROUP]->(g:Group)-[:HAS_OPERATION]->(o:Operation)
        WHERE ID(u) = $user_id
        DETACH DELETE u, g, o
      """
      session.run(delete_operations_query, user_id: @user.id.to_i)
  
      flash[:notice] = 'User and all related data were successfully destroyed.'
      redirect_to root_url
    rescue => e
      flash[:alert] = "Failed to destroy user and related data: #{e.message}"
      redirect_to users_url
    ensure
      session.close
    end
  end

  private

  def set_user
    @user = User.find(params[:id].to_i)
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
