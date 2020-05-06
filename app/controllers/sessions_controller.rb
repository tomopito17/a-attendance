class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user) #7.3deleteremember user
      redirect_back_or user#8.3 Delete「redirect_to user」 # ログイン後にユーザー情報ページにリダイレクトします。
    else
      flash.now[:danger] = '認証に失敗しました。' #7.4 add .now
      render :new
    end
  end
  
  
  def destroy
    #log_out
    # ログイン中の場合のみログアウト処理を実行します。
    log_out if logged_in?
    flash[:success] = 'ログアウトしました。'
    redirect_to root_url
  end
end
