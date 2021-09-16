class AddOvertimeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overtime, :time
    add_column :attendances, :task_memo, :text
    # add_column :attendances, :change_confirmation_status, :integer
    # add_column :attendances, :change_confirmation_approver_id, :integer
    add_column :attendances, :overwork_status, :string
    #add_column :attendances, :overwork_approver_id, :integer
    add_column :attendances, :overday_check, :boolean, default: false
    add_column :attendances, :overwork_sperior, :integer
    add_column :attendances, :indicater_check, :string #A05add overwork_superior 上長A
    #A04
    add_column :attendances, :monthly_confirmation_approver_id, :integer
    add_column :attendances, :monthly_confirmation_status, :integer
    #A05
    add_column :attendances, :change, :boolean, default: false #A05Add

    #A06Add 勤怠編集
    add_column :attendances, :started_before_at, :datetime
    add_column :attendances, :started_edit_at, :datetime
    add_column :attendances, :finished_before_at, :datetime
    add_column :attendances, :finished_edit_at, :datetime
    # A06指示者確認　overwork_status
    add_column :attendances, :indicater_reply, :integer
    #A06 どの上長に申請か
    add_column :attendances, :indicater_check_month, :string
    #A06 1ヶ月勤怠変更 指示者確認のセレクト
    add_column :attendances, :indicater_reply_month, :integer

    #A06 どの上長に申請しているか
    add_column :attendances, :indicater_check_edit, :string

    #A06 指示者確認の「なし」、「承認」、「否認」、「申請中」を入れるカラム
    add_column :attendances, :indicater_reply_edit, :integer
    #A06翌日のチェック入力
    add_column :attendances, :tomorrow_edit, :boolean, default: false

    #A06 1ヶ月承認
    # 承認申請月
    add_column :attendances, :month_approval, :date
    # モーダルの変更ボタン
    add_column :attendances, :change_month, :boolean, default: false
    # お知らせモーダルのメッセージ
    add_column :attendances, :indicater_check_month_anser, :string
    #A06勤怠変更申請
    # 変更前時間や編集用の出勤時間
    add_column :attendances, :change_edit, :boolean, default: false
    add_column :attendances, :indicater_check_edit_anser, :string
      #A09 申請内容を承認したのか
    add_column :attendances, :indicater_check_anser, :string
    #A07確認
    add_column :attendances, :verification, :boolean, default: false
    #A09-1 勤怠修正ログ
    add_column :attendances, :log_checked, :string
  end
end
