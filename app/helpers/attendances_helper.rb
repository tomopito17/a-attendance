module AttendancesHelper#10.6.1add
  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出勤' if attendance.started_at.nil?
      return '退勤' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # どれにも当てはまらなかった場合はfalseを返します。
    return false
  end

  # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。
  def working_times(start, finish)
    format("%.2f", (((finish - start) / 60) / 60.0))
  end
  
  def format_hour(time)
    format("%02d", time.hour)
  end
  
  def format_min(time)
    format("%02d", ((time.min / 15) * 15))
  end
  
  # 不正な値があるか確認するTestNo9
  def attendances_invalid?
    attendances = true
    attendances_params.each do |id, item|
      if item[:started_at].blank? && item[:finished_at].blank?
        next
      elsif item[:started_at].blank? || item[:finished_at].blank?
        attendances = false
        break
      elsif item[:started_at] > item[:finished_at]
        attendances = false
        break
      end
    end
    return attendances
  end

  # 時間外勤務 A05
  def overtime_worked_on(finish, end_time, is_tomorrow)
    #puts is_tomorrow.class ＜----tomorrowの型　確認
    if is_tomorrow    # == true
      # finishとend_timeの'時'と'分'をそれぞれ計算し、差分を合わせるために、分割を60で割る
      format("%.2f", (((finish.hour - end_time.hour) + ((finish.min - end_time.min) / 60.0) + 24)))
    else
      format("%.2f", (((finish.hour - end_time.hour) + ((finish.min - end_time.min) / 60.0))))
    end
  end
end