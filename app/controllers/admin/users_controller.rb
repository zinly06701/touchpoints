class Admin::UsersController < AdminController
  before_action :ensure_organization_manager
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    if current_user.admin?
      @users = User.all.includes(:organization)
    else
      organization = current_user.organization
      @users = organization.users.includes(:organization)
    end
  end

  def show
    @touchpoints = @user.touchpoints
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to admin_user_path(@user), notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to admin_user_path(@user), notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    ensure_admin
    redirect_to(edit_admin_user_path(@user), alert: "Can't delete yourself") and return if @user == current_user

    @user.destroy
    respond_to do |format|
      format.html { redirect_to admin_users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      if admin_permissions?
        params.require(:user).permit(
          :admin,
          :organization_id,
          :organization_manager,
          :email,
          :inactive
        )
      elsif organization_manager_permissions?
        params.require(:user).permit(
          :organization_id,
          :organization_manager,
          :email
        )
      end
    end
end
