class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy]#8.4add_index,8.5.2add_destroy
  before_action :correct_user, only: [:edit, :update]


  def index
      @users = User.paginate(page: params[:page]) #8.4.4 Del_@users = User.all#8.4.1
  end
  

  def show
    # @user = User.find(params[:id])
    # #debugger # インスタンス変数を定義した直後にこのメソッドが実行されます。
  end

  def new
    @user = User.new # ユーザーオブジェクトを生成し、インスタンス変数に代入します。
  end

  def create
    @user = User.new(user_params)#(params[:user])
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

  private


    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    # beforeフィルター
    
    # paramsハッシュからユーザーを取得します。
    def set_user
      @user = User.find(params[:id])
    end
	    
    # ログイン済みのユーザーか確認します。
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "ログインしてください。"
        redirect_to login_url
      end
    end
    
    # アクセスしたユーザーが現在ログインしているユーザーか確認します。
    def correct_user
      redirect_to(root_url) unless current_user?(@user)
      # @user = User.find(params[:id])
      # redirect_to(root_url) unless @user == current_user
    end
    
    	    # システム管理権限所有かどうか判定します。
    def admin_user
      redirect_to root_url unless current_user.admin?
    end
end


=begin
  validates :name, presence: true#validates(:name, presence: true)
=end

