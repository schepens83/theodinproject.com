class UsersController < ApplicationController
  #prepend_before_filter :set_user, :authorized?
  before_action :set_user, only: [:show, :edit, :update]
  before_action :allowed?, only: [:edit, :update]
	
  # GET /trainers
  # GET /trainers.json
  def index
    @users = User.all.paginate :page => params[:page], per_page: 10
  end

  # GET /trainers/1
  # GET /trainers/1.json
  def show
    @authored_posts = current_user.authored_posts
  end

  # CREATE is done by devise

  # NEW is provided by devise

  # GET /trainers/1/edit
  def edit
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE is not provided to user
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
    	if params[:id]
    		@user = User.find(params[:id]) 
    	else
    		@user = User.find(current_user.id)
    	end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.fetch(:user, {}).permit(:firstname, :lastname, :age, :email)
    end

    def allowed?
      redirect_to root_path unless view_context.authorized?
    end
end
