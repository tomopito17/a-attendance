require 'csv'

CSV.generate do |csv|
  column_names = %w(名前 メールアドレス 所属 社員番号 カードID 基本勤務時間 指定勤務開始時間 指定勤務終了時間 上長 管理者 パスワード)
  csv << column_names
  @users.each do |user|
    column_values = [
      user.name,
      user.email,
      user.affiliation,
      user.employee_number,
      user.uid,
      user.basic_work_time,
      user.designated_work_start_time,
      user.designated_work_end_time,
      user.superior
      user.admin
      user.password
    ]
    csv << column_values
  end
end


  # column_names = %w(日付 出社 退社 備考 )
  # csv << column_names
  # @attendances.each do |attendance|
  #   column_values = [
  #     attendance.attendance_date,
  #     attendance.arriving_at,
  #     attendance.leaving_at,
  #     attendance.note,
  #   ]
  #   csv << column_values
  # end