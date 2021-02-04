require 'csv'

CSV.generate do |csv|
  column_names = %w(日付 出社 退社 備考 )
  csv << column_names
  @attendances.each do |attendance|
    column_values = [
      attendance.attendance_date,
      attendance.arriving_at,
      attendance.leaving_at,
      attendance.note,
    ]
    csv << column_values
  end
end