class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: :show
  before_action :admin_or_correct, only: %i(show)

 #logged_in_user 8.4add_index,8.5.2add_destroy,9.3Del show add basicinfo

  def index
    if params[:search].present?
      @users = User.paginate(page: params[:page]).search(params[:search])
    else
      @users = User.paginate(page: params[:page])
    end
   #@users = User.paginate(page: params[:page]) #8.4.4 Del_@users = User.all#8.4.1
   #@users = User.where(activated: true).paginate(page: params[:page]).search(params[:search])
  end
  

  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
    # @user = User.find(params[:id])
    #first_day = Date.current.beginning_of_month
    #last_day = @first_day.end_of_month
  end
# #debugger # インスタンス変数を定義した直後にこのメソッドが実行されます。

  def new
    @user = User.new # ユーザーオブジェクトを生成し、インスタンス変数に代入します。
  end

  def create
    @user = User.new(user_params) #9.4(params[:user])
    if @user.save
      log_in @user # 保存成功後、ログインします。
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user # 保存に成功した場合は、ここに記述した処理が実行されます。
    else
      render :new
    end
  end


  def edit
    #@user = User.find(params[:id])
  end

  def update # 8.1.2
   # @user = User.find(params[:id]) #Delete8.2
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"# 更新に成功した場合の処理を記述します。
      redirect_to @user
    else
      render :edit      
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

	
  def edit_basic_info
  end
	
  def update_basic_info #9.3.2 
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"# 更新成功時の処理
    else# 更新失敗時の処理
        flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
	

  private

    def user_params #9.1.3department
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
    end

    def basic_info_params
      params.require(:user).permit(:department, :basic_time, :work_time)
    end
    
end
    # beforeフィルター
    # paramsハッシュからユーザーを取得します。
    # def set_user 11.1.3 Move
    #   @user = User.find(params[:id])
    # end

    # # ログイン済みのユーザーか確認します。
    # def logged_in_user
    #   unless logged_in?
    #     store_location
    #     flash[:danger] = "ログインしてください。"
    #     redirect_to login_url
    #   end
    # end
 
    # # アクセスしたユーザーが現在ログインしているユーザーか確認します。
    # def correct_user
    #   redirect_to(root_url) unless current_user?(@user)
    #   # @user = User.find(params[:id])
    #   # redirect_to(root_url) unless @user == current_user
    # end
 
    # # システム管理権限所有かどうか判定します。
    # def admin_user
    #   redirect_to root_url unless current_user.admin?
    # end

=begin
  validates :name, presence: true#validates(:name, presence: true)
=end