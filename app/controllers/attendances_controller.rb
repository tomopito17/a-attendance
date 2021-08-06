class AttendancesController < ApplicationController
  include AttendancesHelper
  before_action :set_user, only: [:edit_one_month, :update_one_month]#11.3.4 :update_one_month add A03 overworkform
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month] #11.3.4
  before_action :set_one_month, only: [:edit_one_month ]

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


  def index #A03
    @user = User.find(params[:user_id]) #A03
    @seniors = User.where(superior: true).where.not(id: @user.id) #A03
    #上長IDを自分以外にする

    #A04    表示期間の勤怠データを日付順にソートして取得 
    #show.html.erb、 <% @attendances.each do |attendance| %>からの情報
    @attendances = @user.attendances.where('attendance_date >= ? and attendance_date <= ?', @first_day, @last_day).order("attendance_date ASC")
    
    # 上長画面で一ヶ月分勤怠申請のお知らせをカウントする
    @monthly_confirmation_count = Attendance.monthly_confirmation(current_user)
  end

  def overwork_form
    @user = User.find(params[:user_id])
    @attendance = @user.attendances.find(params[:id])
    @seniors = User.where(superior: true).where.not(id: @user.id)
  end

  def update_overwork #A04残業更新
    @user = User.find(params[:user_id])
    @attendance = @user.attendances.find(params[:id])
      #チェックボックスはifで分岐だけでTBlのDBは入れてない
    if params[:overday_check] #A05add
      @attendance.overtime = @attendance.overtime + 1.day
    end 
    params[:attendance][:overwork_status] = "申請中" #A05追加
    @attendance.task_memo = params[:attendance][:task_memo] #A05追加
    if @attendance.update_attributes(overwork_params)
      flash[:success] = "残業を申請しました。" # 更新成功時の処理
    else # 更新失敗時の処理
      flash[:danger] = "残業申請に失敗しました。"
    end
    redirect_to user_path(@user)
  end
 
  

  def edit_one_month
    @attendance = Attendance.find(params[:id])
    #@seniors = User.where(superior: true).where.not( id: current_user.id)
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
  
  #A04残業承認
  def overwork_confirmation_form
    @user = User.find(params[:user_id]) #ユーザ定義
    @attendances = Attendance.where(overwork_status: "申請中", overwork_sperior: @user.id).order(:user_id).group_by(&:user_id)
    #ログイン中の上長名表示、申請ステータス選択
  end

  #A05 残業承認モーダル更新
  def update_overwork_confirmation_form
    ActiveRecord::Base.transaction do
      o1 = 0
      o2 = 0
      o3 = 0
      overwork_confirmation_form_params.each do |id, item|
        if (item[:overwork_status].present?) && (item[:change] == "1" )
           #↑残業申請ステータスに値入力の有無と変更の値入力確認 
          if (item[:overwork_status] == "なし") || (item[:overwork_status] == "申請中") || (item[:overwork_status] == "承認") || (item[:overwork_status] == "否認")
            attendance = Attendance.find(id)
            user = User.find(attendance.user_id)
            #残業申請の申請ステータス変更なし
            if item[:overwork_status] == "なし"
              o1 += 1
              item[:overtime] = nil
              item[:overday_check] = nil
              #item[:task_memo] = nil
            elsif item[:overwork_status] == "申請中"
              o1 += 1
              item[:overtime] = nil
              item[:overday_check] = nil
              #item[:task_memo] = nil
              #残業承認
            elsif item[:overwork_status] == "承認"
              o2 += 1
              flash[:success] = "残業申請を承認しました"
            #残業否認
            elsif item[:overwork_status] == "否認"
              item[:overtime] = nil
              item[:overday_check] = nil
              #item[:task_memo] = nil
              o3 += 1
              flash[:danger] = "残業申請を否認しました"
            end
            attendance.update_attributes!(item)
          end
        else
          flash[:danger] = "指示者確認の入力、または変更にチェックを入れて下さい" 
          redirect_to user_url(params[:user_id])
          return
        end
      end
      flash[:success] = "指定の内容に更新完了しました"
      flash[:success] = "【残業申請】　#{o1}件未完了、　#{o2}件承認、　#{o3}件否認しました"
      redirect_to user_url(params[:user_id])
      return
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効なデータ入力があった為、更新をキャンセルしました"
    redirect_to overwork_confirmation_form_user_attendances_path(@user)
  end


  #A04上長1ヶ月勤怠承認
  def monthly_confirmation_form
    #ユーザ定義
    @user = User.find(params[:user_id])
    #未承認かつidがcurrent_user
    @attendances = Attendance.where(monthly_confirmation_status: :pending, monthly_confirmation_approver_id: current_user.id)
    #ユーザー（user_id)ごとに勤怠のオブジェクトを分ける
    tmp_pending_users = @attendances.group_by(&:user_id)
    #未承認のユーザーの名前と、　　＃まだ一ヶ月分勤怠申請
    @pending_users = {}

  end


   private #11.3.2add
  
  # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end
    
    def overwork_params #A04add
      params.require(:attendance).permit(:overtime, :overday_check, :task_memo, :overwork_sperior, :overwork_status)
    end

    def overwork_confirmation_form_params #A05 attendancesテーブルの（指示者確認、変更）
      params.require(:user).permit(attendances: [:task_memo, :overwork_status, :change, :indicater_check, :overtime, :indicater_check_anser])[:attendances]
    end


    # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end  
    end

end