class AttendancesController < ApplicationController
  include AttendancesHelper
  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_one_month_notice, :update_month_approval, :monthly_confirmation_form ]#11.3.4 :update_one_month add A03 overworkform 
  #A06 edit_one_month_notice, :update_month_approval, :monthly_confirmation_form
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month] #11.3.4 
  before_action :admin_user, only: [:index, :destroy, :edit_basic_info] #A09-1
  before_action :set_one_month, only: [:edit_one_month ]
  before_action :admin_not#A09-1
  before_action :correct_user_a, only: [:log] #A07

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

  def update  #10.5.3
    #debugger
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
   #  @attendance.user_id = current_user.id
   # #指示者確認・パラメーターでユーザーの名前を検索してidを入れる
   #  @attendance.overwork_approver_id = User.where(name: params[:user][:name]).first.id
   #  @attendance.task_memo = params[:attendance][:task_memo]
   #  if @attendance.save
   #   redirect_to attendances_path, notice: '残業申請を送付しました。'
   #  else
   #  redirect_to attendances_path, notice: '残業申請は失敗しました。'
   #  end
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
    #iddebugger
    @user = User.find(params[:user_id])
    @attendance = @user.attendances.find(params[:id])
    @seniors = User.where(superior: true).where.not(id: @user.id)
  end

  def update_overwork #A04残業更新
    #debugger
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
      flash[:danger] = "残業申請に失敗しました。指示者確認を更新、または変更にチェックを入れて下さい"
    end

    redirect_to user_path(@user)
  end


  def edit_one_month #A06
    #debugger
    #attendance = @user.attendances.find(params[:id])#A06
    @attendance = Attendance.find(params[:id])
    @seniors = User.where(superior: true).where.not( id: current_user.id)
  end

    # 勤怠変更申請お知らせモーダル
  def edit_one_month_notice
    @users = User.eager_load(:attendances).where(attendances: {indicater_reply_edit: "申請中", indicater_check_edit: current_user.name})
    
     #@users = User.joins(:attendances).group("users.id").where(attendances: {indicater_reply_edit: "申請中"})
    #  @indicater_edits = @users.where(attendances: {indicater_check_edit: current_user.name}) # 変更箇所：　上長の選択
    #  @attendances = Attendance.where.not(started_edit_at: nil, finished_edit_at: nil, note: nil, indicater_reply_edit: nil).order("worked_on ASC")
  end

  def update_one_month  #debugger
    ActiveRecord::Base.transaction do # トランザクションを開始します。
        c1 = 0 #A06 カラムを更新した件数を入れる変数を定義
        attendances_params.each do |id, item| #A06 ストロングパラメータのidと各カラムを配列で回す処理
          @attendance = Attendance.find(id) # attendancesテーブルから一つのidを探す
          if item[:indicater_check_edit].present? # 上長が選択されていることを確認
            if item[:started_edit_at].blank? && item[:finished_edit_at].present? #時間が入ってない場合はエラー
              flash[:danger] = "出勤時刻が存在しません"
              redirect_to attendances_edit_one_month_user_url(date: params[:date])
              return
            elsif item[:started_edit_at].present? && item[:finished_edit_at].blank? #出勤時間が入っているのに退勤時間が入ってない場合はエラー
              flash[:danger] = "退勤時間が存在しません"
              redirect_to attendances_edit_one_month_user_url(date: params[:date])
              return
              # 翌日チェックがなくて、さらに出勤時間よりも退勤時間が小さい場合はエラー
            elsif item[:started_edit_at].present? && item[:finished_edit_at].present? && item[:tomorrow_edit] == "0" && item[:started_edit_at].to_s > item[:finished_edit_at].to_s
              flash[:danger] = "入力時刻に誤りがあります"
              redirect_to attendances_edit_one_month_user_url(date: params[:date])
              return
            end
            c1 += 1
            @attendance.update_attributes!(item)
          end
      end
      if c1 > 0
        flash[:success] = "勤怠変更を#{c1}件受け付けました"
        redirect_to user_url(@user)
      else
        flash[:danger] = "上長を選択して下さい"
        redirect_to attendances_edit_one_month_user_url(date: params[:date])
        return
      end
    end
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
    return
  end
      #当日より未来の編集は不可    (#adminユーザのみ可能)
      #if attendance.attendance_day > Date.current# && !current_user.admin?
       # flash[:warning] = '明日以降の勤怠編集は出来ません。'
  # 勤怠B1ヶ月更新
  #def update_one_month 
  #  ActiveRecord::Base.transaction do # トランザクションを開始します。
  #     if attendances_invalid?#No9test
  #       attendances_params.each do |id, item|
  #         attendance = Attendance.find(id)
  #         attendance.update_attributes!(item)
  #       end
  #       flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
  #       redirect_to user_url(date: params[:date])
  #     else #end-movetestNo9
  #       flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
  #       redirect_to user_url(date: params[:date])
  #     end#move.No9test
  #   end#add.No9test
  # rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
  #   flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
  #   redirect_to attendances_edit_one_month_user_url(date: params[:date])
  # end

  #A04残業承認
  def overwork_confirmation_form
    @user = User.find(params[:user_id]) #ユーザ定義
    @attendances = Attendance.where(overwork_status: "申請中", overwork_sperior: @user.id).order(:user_id, :id).group_by(&:user_id)
    #debugger
    #binding.pry
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
              #item[:overtime] = nil
              #item[:overday_check] = nil
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


  # ここからは勤怠の1ヶ月分の勤怠承認に関する処理
  # 勤怠承認申請
  # def update_month_approval
  #   @attendance = @user.attendances.find_by(worked_on: params[:user][:month_approval]) #特定したユーザーの現在の月の取得
  #   if month_approval_params[:indicater_check_month].present?
  #     @attendance.update_attributes(month_approval_params)
  #     flash[:success] = "勤怠承認申請を受け付けました"
  #   else
  #     flash[:danger] = "上長を選択して下さい"
  #   end
  #   redirect_to user_url(@user)
  # end

  # 1ヶ月分の勤怠承認モーダル
  def monthly_confirmation_form     #edit_month_approval_notice
      #debugger
      @users = User.joins(:attendances).group("users.id").where(attendances: {indicater_reply_month: "申請中"})
      @indicater_approvals = @users.where(attendances: {indicater_check_month: current_user.name}) # 変更箇所：　上長の選択
      @attendances = Attendance.where.not(month_approval: nil, indicater_reply_month: nil).order("month_approval ASC")
  end

  #A06 1ヶ月分の勤怠承認更新
  def update_month_approval_notice
    ActiveRecord::Base.transaction do
      a1 = 0
      a2 = 0
      a3 = 0
      month_approval_notice_params.each do |id, item|
      if item[:indicater_reply_month].present?
        if (item[:change_month] == "1") && (item[:indicater_reply_month] == "なし" || item[:indicater_reply_month] == "承認" || item[:indicater_reply_month] == "否認")
        attendance = Attendance.find(id)
        user = User.find(attendance.user_id)
          if item[:indicater_reply_month] == "なし"
            a1 += 1
            item[:month_approval] = nil
            item[:indicater_check_month] = nil
          elsif item[:indicater_reply_month] == "承認"
            a2 += 1
            attendance.indicater_check_month_anser = "1ヶ月分の勤怠を承認しました"
          elsif item[:indicater_reply_month] == "否認"
            a3 += 1
            attendance.indicater_check_month_anser = "1ヶ月分の勤怠を否認しました"
          end
          attendance.update_attributes!(item)
        else
            flash[:danger] = "指示者確認を更新、または変更にチェックを入れて下さい"
            redirect_to user_url(params[:user_id])
            return
          end
        end
      end
      flash[:success] = "【1ヶ月の承認申請】　#{a1}件なし、#{a2}件承認、#{a3}件否認しました"
      redirect_to user_url(params[:user_id])
      return
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました"
    redirect_to monthly_confirmation_form_user_attendance_url(@user, item)
  end


  #A06 勤怠承認申請
  def update_month_approval
    #debugger
    @attendance = @user.attendances.find_by(worked_on: params[:user][:month_approval]) #特定したユーザーの現在の月の取得
    if month_approval_params[:indicater_check_month].present?
      @attendance.update_attributes(month_approval_params)
      flash[:success] = "勤怠承認申請を受け付けました"
    else
      flash[:danger] = "上長を選択して下さい"
    end
    redirect_to user_url(@user)
  end

  # A07勤怠修正log処理
  def log
    @user = User.find(params[:user_id])
    if params["worked_on(1i)"].present? && params["worked_on(2i)"].present? # もし受け取った値worked_on(1i)は年、(2iは月)
      year_month = "#{params["worked_on(1i)"]}/#{params["worked_on(2i)"]}" # 受け取ったworked_onの年と月を"年/月"という文字列にしてyear_monthに代入
      @day = DateTime.parse(year_month) if year_month.present? # year_monthが存在した場合は、Datetimeを日付に変換する
      # @attendancesに@user.attendancesからindicater_reply_editから承認されたモノと、worked_on:カラムが@dayのモノを全て取得する
      @attendances = @user.attendances.where(indicater_reply_edit: "承認").where(worked_on: @day.all_month)
    else
      @attendances = @user.attendances.where(indicater_reply_edit: "承認").order("worked_on ASC")
    end
  end

  #A07 勤怠変更申請お知らせモーダル更新
  def update_one_month_notice
    ActiveRecord::Base.transaction do
      e1 = 0
      e2 = 0
      e3 = 0
      attendances_notice_params.each do |id, item|
        if item[:indicater_reply_edit].present?
          if (item[:change_edit] == "1") && (item[:indicater_reply_edit] == "なし" || item[:indicater_reply_edit] == "承認" || item[:indicater_reply_edit] == "否認")
            attendance = Attendance.find(id)
            user = User.find(attendance.user_id)
            if item[:indicater_reply_edit] == "なし"
              e1 += 1
              item[:started_edit_at] = nil
              item[:finished_edit_at] = nil
              item[:tomorrow_edit] = nil
              item[:note] = nil
              item[:indicater_check_edit] = nil
            elsif item[:indicater_reply_edit] == "承認"
              if attendance.started_before_at.blank?
                item[:started_before_at] = attendance.started_at
              end
              item[:started_at] = attendance.started_edit_at
              if attendance.finished_before_at.blank?
                item[:finished_before_at] = attendance.finished_at
              end
              item[:finished_at] = attendance.finished_edit_at
              item[:log_checked] = attendance.indicater_check_edit
              item[:indicater_check_edit] = nil
              e2 += 1
              attendance.indicater_check_anser = "勤怠変更申請を承認しました"
            elsif item[:indicater_reply_edit] == "否認"
              item[:started_edit_at] = nil
              item[:finished_edit_at] = nil
              item[:tomorrow_edit] = nil
              item[:note] = nil
              item[:indicater_check_edit] = nil
              e3 += 1
              attendance.indicater_check_edit_anser = "勤怠変更申請を否認しました"
            end
            attendance.update_attributes!(item)
          end
        else
          flash[:danger] = "指示者確認を更新、または変更にチェックを入れて下さい"
          redirect_to user_url(params[:user_id])
          return
        end
      end
      flash[:success] = "【勤怠変更申請】  #{e1}件なし、 #{e2}件承認、 #{e3}件を否認しました"
      redirect_to user_url(params[:user_id])
      return
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効なデータがあった為、更新をキャンセルしました"
    redirect_to edit_one_month_notice_user_attendance_url(@user, item)
  end



  #A04上長1ヶ月勤怠承認
  # def monthly_confirmation_form
  #   #ユーザ定義
  #   @user = User.find(params[:user_id])
  #   #未承認かつidがcurrent_user
  #   @attendances = Attendance.where(monthly_confirmation_status: :pending, monthly_confirmation_approver_id: current_user.id)
  #   #ユーザー（user_id)ごとに勤怠のオブジェクトを分ける
  #   tmp_pending_users = @attendances.group_by(&:user_id)
  #   #未承認のユーザーの名前と、　　＃まだ一ヶ月分勤怠申請
  #   @pending_users = {}
  # end


  #A06 勤怠変更処理
  # def update_one_month
  #   ActiveRecord::Base.transaction do # トランザクションを開始します。
  #     c1 = 0 # カラムを更新した件数を入れる変数を定義
  #     attendances_params.each do |id, item| # ストロングパラメータのidと各カラムを配列で回す処理
  #       @attendance = Attendance.find(id) # attendancesテーブルから一つのidを探す
  #         if item[:indicater_check_edit].present? # 上長が選択されていることを確認
  #           if item[:started_edit_at].blank? && item[:finished_edit_at].present? #時間が入ってない場合はエラー
  #             flash[:danger] = "出勤時刻が存在しません"
  #             redirect_to attendances_edit_one_month_user_url(date: params[:date])
  #             return
  #           elsif item[:started_edit_at].present? && item[:finished_edit_at].blank? #出勤時間が入っているのに退勤時間が入ってない場合はエラー
  #             flash[:danger] = "退勤時間が存在しません"
  #             redirect_to attendances_edit_one_month_user_url(date: params[:date])
  #             return
  #             # 翌日チェックがなくて、さらに出勤時間よりも退勤時間が小さい場合はエラー
  #           elsif item[:started_edit_at].present? && item[:finished_edit_at].present? && item[:tomorrow_edit] == "0" && item[:started_edit_at].to_s > item[:finished_edit_at].to_s
  #             flash[:danger] = "入力時刻に誤りがあります"
  #             redirect_to attendances_edit_one_month_user_url(date: params[:date])
  #             return
  #           end
  #           c1 += 1
  #           @attendance.update_attributes!(item)
  #         end
  #     end
  #     if c1 > 0
  #       flash[:success] = "勤怠変更を#{c1}件受け付けました"
  #       redirect_to user_url(@user)
  #     else
  #       flash[:danger] = "上長を選択して下さい"
  #       redirect_to attendances_edit_one_month_user_url(date: params[:date])
  #       return
  #     end
  #   end
  #   rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
  #   flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
  #   redirect_to attendances_edit_one_month_user_url(date: params[:date])
  #   return
  #  end

  private #11.3.2add

  # 1ヶ月分の勤怠情報を扱います。A03,A06カラム 追加
  def attendances_params
    params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :started_edit_at, :finished_edit_at, :tomorrow_edit, :indicater_check_edit, :indicater_reply_edit, :task_memo])[:attendances]
  end

  def overwork_params #A04add #A07修正add
    params.require(:attendance).permit(:overtime, :overday_check, :task_memo, :overwork_sperior, :overwork_status) #indicater_check
  end

  def overwork_confirmation_form_params #A05 attendancesテーブルの（指示者確認、変更）
    params.require(:user).permit(attendances: [:task_memo, :overwork_status, :change, :indicater_check, :overtime, :indicater_check_anser])[:attendances]
  end

    #A09-1 勤怠編集のお知らせモーダル
  def attendances_notice_params
    params.require(:user).permit(attendances: [:started_at, :finished_at, :started_before_at, :finished_before_at, :started_edit_at, :finished_edit_at, :note, :indicater_reply_edit, :change_edit, :log_checked])[:attendances]
  end

  #A06 1ヶ月承認申請
  def month_approval_params
    # attendanceテーブルの（承認月、指示者確認、どの上長なのか？）
    params.require(:user).permit(:month_approval, :indicater_reply_month, :indicater_check_month)
  end

    # 1ヶ月承認申請お知らせモーダル
  def month_approval_notice_params
    # attendancesテーブルの（承認月、指示者確認、変更、どの上長なのか？）
    params.require(:user).permit(attendances: [:month_approval, :indicater_reply_month, :change_month, :indicater_check_month])[:attendances]
  end
# A06勤怠1ヶ月編集
    # def attendances_notice_params
    #   params.require(:user).permit(attendances: [:started_at, :finished_at, :started_before_at, :finished_before_at, :started_edit_at, :finished_edit_at, :note, :indicater_reply_edit, :change_edit, :log_checked])[:attendances]
    # end

  # 管理権限者、または現在ログインしているユーザーを許可します。
  def admin_or_correct_user
    @user = User.find(params[:user_id]) if @user.blank?
    unless current_user?(@user) || current_user.admin?
      flash[:danger] = "編集権限がありません。"
      redirect_to(root_url)
    end
  end

end