module PhotoSchedule
  def random_schedule
    i = 0
    list_of_lists = []

    #26 weeks of treatment
    while i < 26
      n = 0
      list = []

      #Account for changing frequency after 2 months
      if i < 8
        mod = 0
      else
        mod = 1
      end

      #Can vary from 1 to 3 Times a week
      while n < rand(2 - mod..3 - mod)
        day = -1
        until day != -1 && !(list.include? day)
          day = rand(1..5)
        end
        list.append(day)
        n += 1
      end

      list_of_lists.append(list)
      i += 1
    end
    return list_of_lists
  end

  def every_day_schedule
    i = 0
    list_of_lists = []
    while i < 26
      n = 0
      list = [1, 2, 3, 4, 5, 6, 7]
      list_of_lists.append(list)
      i += 1
    end
    return list_of_lists
  end
end
