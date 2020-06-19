DailyReport.all.each do |report|
    number = rand(10)
    report.update!(doing_okay: (number < 9) )
end