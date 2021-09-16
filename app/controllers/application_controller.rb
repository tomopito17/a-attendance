class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  $days_of_the_week = %w{日 月 火 水 木 金 土}
  
  #add10.3 ページ出力前に1ヶ月分のデータの存在を確認・セットします。11.1.3Del
  # def set_one_month 
  #   @first_day = params[:date].nil? ?
  #   Date.current.beginning_of_month : params[:date].to_date
  #   @last_day = @first_day.end_of_month
  #   one_month = [*@first_day..@last_day]
  
    # @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
  # beforフィルター
  # paramsハッシュからユーザーを取得します。 11.1.3D_el
  def set_user
    #debugger
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
  end

    # A07ログ専用のアクセスしたユーザーが現在ログインしているユーザーなのかを確認する
  def correct_user_a
    @user = User.find(params[:user_id])
    unless current_user?(@user)
      flash[:danger] = "他者のページは閲覧できません"
      redirect_to root_url
    end
  end

  # システム管理権限所有かどうか判定します。
  def admin_user
    redirect_to root_url unless current_user.admin?
  end


  #A09
  def admin_not
    if current_user.admin?
    flash[:success] = "管理者は勤怠登録できません。"
      redirect_to root_url
    end
  end

  #A09-1
  def correct_not
    unless current_user == @user
      flash[:danger] = "他者のページは閲覧できません。"
      redirect_to root_url
    end
  end

  # @userが定義されている上で使用する Tutorial
  def admin_or_correct
    unless current_user?(@user) || current_user.admin?
      flash[:danger] = "権限がありません。"
      redirect_to root_url
    end 
  end


# ページ出力前に1ヶ月分のデータの存在を確認・セットします。
  def set_one_month
    @first_day = params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day] # 対象の月の日数を代入します。
    # ユーザーに紐付く一ヶ月分のレコードを検索し取得します。
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
   #@attendances = @user.attendances.where(worked_on: @first_day..@last_day)
    unless one_month.count == @attendances.count # それぞれの件数（日数）が一致するか評価します。
      ActiveRecord::Base.transaction do # トランザクションを開始します。
        # 繰り返し処理により、1ヶ月分の勤怠データを生成します。
          one_month.each { |day| @user.attendances.create!(worked_on: day) }
      end
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)  #11.3
    end

  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end
end




    # unless one_month.count == @attendances.count
    #   ActiveRecord::Base.transaction do
    #     one_month.each { |day| @user.attendances.create!(worked_on: day) }
    #   end
    #   @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    # end
  
#   rescue ActiveRecord::RecordInvalid
#     flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
#     redirect_to root_url
#   end
# end

# # システム管理権限所有かどうか判定します。
# 	  def admin_user
# 	    redirect_to root_url unless current_user.admin?
# 	  end
	
# 	  # ページ出力前に1ヶ月分のデータの存在を確認・セットします。
#   def set_one_month #一度削除して復帰11.1.3
#     @first_day = Date.current.beginning_of_month
