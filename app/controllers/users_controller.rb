class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info, :working_employees, :index]
  before_action :set_one_month, only: :show
  before_action :admin_or_correct, only: %i(show)
 #logged_in_user 8.4add_index,8.5.2add_destroy,9.3Del show add basicinfo

# CSVimport
 require 'active_support/all'
  # def import csv
  #   if params[:csv_file].blank?
  #     flash[:dnger] = "ファイルが未選択です。ファイルを選択してください。"
  #   elseif
  #    File.extname(params[:csv_csv_file])
  #    flash[:danger]= "CSVファイルを選択してください。"
  #    #params[:csv_file].blank?
  #    #redirect_to action: 'index', error: '読み込むCSVを選択してください'
  #   else
  #     count = User.import(params[*csv_file])
  #     flash[:success] = "#{ count.to_s}件のユーザー情報を追加しました。"
  #   end
  #    redirect_to users_path
  # end



  def index
      @users = User.where.not(id: 1)
      respond_to do |format|
      format.html do
      end
      format.csv do
        send_data render_to_string,filename:"original_filename.csv",type: :csv
      end
    end

    #勤怠B
    # if params[:search].present?
    #   @users = User.paginate(page: params[:page]).search(params[:search])
    # else
    #   @users = User.paginate(page: params[:page])
    # end


   #Tutorial
   #@users = User.paginate(page: params[:page]) #8.4.4 Del_@users = User.all#8.4.1
   #@users = User.where(activated: true).paginate(page: params[:page]).search(params[:search])
  end

  def show
    #debugger
    @worked_sum = @attendances.where.not(started_at: nil).count
    @overtime = Attendance.where(overwork_status: "申請中", overwork_sperior: @user.id).count 
    #debugger
    #overwork_status: "申請中"
    #A06 1ヶ月申請ステータス
    @month = Attendance.where(indicater_reply_month: "申請中", indicater_check_month: @user.name).count
    @change = Attendance.where(indicater_reply_edit: "申請中", indicater_check_edit: @user.name).count
    @seniors = User.where(superior: true).where.not(id: current_user.id)
    #@attendance = @user.attendances.find(params[:id])
    @attendance = @user.attendances.find_by(worked_on: @first_day)
    #A06仮初期値
    
    # # 残業のカウント
    @overtime_count = current_user.attendances.where(overwork_status: "申請中").count
    @overtime_not_count = current_user.attendances.where(overwork_status: "否認").count
    # # 勤怠変更のカウント
    @change_count = current_user.attendances.where(indicater_reply_edit: "申請中").count
    @change_not_count = current_user.attendances.where(indicater_reply_edit: "否認").count
    #A07 # 1ヶ月勤怠申請のカウント
    @month_count = current_user.attendances.where(indicater_reply_month: "申請中").count
    @month_not_count = current_user.attendances.where(indicater_reply_month: "否認").count

  #A07 csv出力エクスポート
    respond_to do |format|
      format.html
      filename = @user.name + "：" + l(@first_day, format: :middle) + "分" + " " + "勤怠"
      format.csv { send_data render_to_string, type: 'text/csv; charset=shift_jis', filename: "#{filename}.csv" }
    end
    # csv出力
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

  def import_csv  #importCSV
    if params[:file].blank?
      flash[:waring]= "CSVファイルが選択されていません。"
      redirect_to users_url
    else
      User.import_csv(params[:file])
      redirect_to users_url, notice: "ユーザーを追加しました"
    end
  end

    # User.rbに記述すべきか確認
  #   def users_csv(file)
  #    CSV.foreach(file.path, headers: true) do |row|
  #     @User = User.new
  #     @User.attributes = row.to_hash.slice(*csv_attributes)
  #     @user.save!
  #   end
  # end

 #A05 「勤怠を確認する」ページ
  def verification
    @user = User.find(params[:id])
    # 通知モーダルの確認ボタンを押下時にparams[：worked_on]にday.worked_onを入れて飛ばしたので、それをfind_byで取り出し
    @attendance = Attendance.find_by(worked_on: params[:worked_on])
    @first_day = @attendance.worked_on.beginning_of_month
    @last_day = @first_day.end_of_month
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    @worked_sum = @attendances.where.not(started_at: nil).count
  end

    def working_employees #A07
    # ユーザーモデルから勤怠達を取得
    @users = User.all.includes(:attendances)
  end

  private

    def user_params #9.1.3department
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation,
      :employee_number, :uid, :basic_work_time, :designated_work_start_time, :designated_work_end_time)
    end

    def basic_info_params
      params.require(:user).permit(:affiliation, :basic_work_time, :designated_work_start_time, :designated_work_end_time)
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