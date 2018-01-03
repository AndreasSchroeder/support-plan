module SemesterBreakPlansHelper

  def name_semester_break
    now = Time.now
    if now.month < 4
        add = -1
      elsif now.month < 10
        add = 1
      else
        add = 0
    end
    if now.month < 4 || now.month >= 10
      return "Semesterferien WS#{now.year + add}/#{now.year + add + 1}->SS#{now.year + add + 1} "
    else
      return "Semesterferien SS#{now.year}->WS#{now.year}/#{now.year + add}"
    end

  end

end
