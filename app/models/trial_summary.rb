class TrialSummary < ActiveModelSerializers::Model

    include DashboardSQL
    
    def patients
        {
            active: Patient.active.count,
            pending: Patient.pending.count,
            priorities: priority_summary
        }
    end

    def photos
        return(
            {
                number_requested: PhotoDay.requested.count,
                number_of_submissions: PhotoReport.all.count,
                number_conclusive: PhotoReport.where(approved: true).count,
                today: {
                  number_requested: PhotoDay.where(date: Date.today).count,
                  number_of_submissions: PhotoReport.where(date: Date.today).count
                }
            }
        )
    end

    private

    def exec_query(query)
        sql = ActiveRecord::Base.sanitize_sql [query]
        return ActiveRecord::Base.connection.exec_query(sql).to_a
      end

    def priority_summary
        hash = {}
        exec_query(SUMMARY_OF_PRIORITIES).each do |line|
          case line["priority"]
          when 0
            hash["low"] = line["count"]
          when 1
            hash["medium"] = line["count"]
          when 2
            hash["high"] = line["count"]
          when 3
            hash["new"] = line["count"]
          else
            puts("Unexpected SQL Return for priority summary")
          end
        end
        return hash
      end
end
