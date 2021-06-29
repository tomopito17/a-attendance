class AttendancesController < ApplicationController
  include AttendancesHelper
  before_action :set_user, only: [:edit_one_month, :update_one_month, :overwork_form]#11.3.4 :update_one_month add A03 overworkform
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month] #11.3.4
  before_action :set_one_month, only: [:edit_one_month ,:overwork_form]

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

  def update  #10.5.3
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG #10.5.3Delflash[:danger] = "勤怠登録に失敗しました。やり直してください。"
      end
    elsif @attendance.finished_at.nil?  #10.6.2
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user

      #A03　残業申請　モーダル　インスタンス　チェックボックスはifで分岐だけでデータベースには入れない　
    if params[:overday_check]
      @attendance.overtime = @attendance.overtime + 1.day
    end 
    
    # @attendance.user_id = current_user.id
    # #指示者確認・パラメーターでユーザーの名前を検索してidを入れる
    # @attendance.overwork_approver_id = User.where(name: params[:user][:name]).first.id
    # @attendance.task_memo = params[:attendance][:task_memo]
    # if @attendance.save
    #   redirect_to attendances_path, notice: '残業申請を送付しました。' 
    # else
    #   redirect_to attendances_path, notice: '残業申請は失敗しました。' 
    # end
    
  end
  
  def overwork_form
    @attendance = Attendance.find(params[:id])
    @seniors = User.where(superior: true).map(&:name)
  end
    
    #A03残業申請　値入力確認
    # tmp_date = @attendance.attendance_date
    # tmp_hour = params[:attendance][:overtime].split(":")[0].to_i
    # tmp_min = params[:attendance][:overtime].split(":")[1].to_i
    # @attendance.overtime = tmp_date + tmp_hour.hour + tmp_min.minute
    
    # #チェックボックスはifで分岐だけでデータベースには入れない
    # if params[:overday_check]
    #   @attendance.overtime = @attendance.overtime + 1.day
    # end 
    
    # @attendance.user_id = current_user.id
    # #指示者確認・パラメーターでユーザーの名前を検索してidを入れる
    # @attendance.overwork_approver_id = User.where(name: params[:user][:name]).first.id
    # @attendance.task_memo = params[:attendance][:task_memo]
    # if @attendance.save
    #   redirect_to attendances_path, notice: '残業申請を送付しました。' 
    # else
    #   redirect_to attendances_path, notice: '残業申請は失敗しました。' 
    # end

  

  def edit_one_month
  end
  
  def update_one_month
    #debugger
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      #当日より未来の編集は不可    (#adminユーザのみ可能)
      #if attendance.attendance_day > Date.current# && !current_user.admin?
       # flash[:warning] = '明日以降の勤怠編集は出来ません。'
      if attendances_invalid?#No9test
        attendances_params.each do |id, item|
          attendance = Attendance.find(id)
          attendance.update_attributes!(item)
        end
        flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
        redirect_to user_url(date: params[:date])
      else#end-movetestNo9
        flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
        redirect_to user_url(date: params[:date])
      end#move.No9test
    end#add.No9test
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  # def index  #A03残業申請　変数定義
  #   # @attendances = @user.attendances.where('attendance_date >= ? and attendance_date <= ?', @first_day, @last_day).order("attendance_date ASC")
  #   # @seniors = User.where(is_senior: true).map(&:name)
    
  # end

  #A03
  # def edit
  #   @attendance = Attendance.find(params[:id])
  #   @superior = User.where(superior: true).map(&:name)
  #   #@days_of_the_week = %w[日 月 火 水 木 金 土]#youbi
  # end

  private #11.3.2add
  
  # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end
    
    # beforeフィルター
	
    # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end  
    end
end