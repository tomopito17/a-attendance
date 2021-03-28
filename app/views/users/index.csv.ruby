require 'csv'

CSV.generate do |csv|
  column_names = %w(名前 メールアドレス 所属 社員番号 カードID 基本勤務時間 指定勤務開始時間 指定勤務終了時間 管理者)
  csv << column_names
  @users.each do |user|
    column_values = [
      user.name,
      user.email,
      user.role,
      user.employee_number,
      user.card_id,
      user.base_attendance_time,
      user.start_attendance_time,
      user.end_attendance_time,
      user.admin,
    ]
    csv << column_values
  end
end