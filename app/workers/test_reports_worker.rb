require "sidekiq-scheduler"

#This worker is used to aide usability testing, creating fake reports for mock patients
class TestReportsWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform()
    #Ensure that this will only run when the environment = development
    if (Rails.env.development?)
      ActiveRecord::Base.transaction do
        
        #Choose user_ids based on which development deployment we are working with 
        patient_ids = (ENV["URL_API"] == "http://localhost:5062") ? [33,5,12] : [100, 101, 102]
        accounts = Patient.where(id:  patient_ids)
        accounts.each do |patient|
            patient.add_photo_day();
            patient.create_seed_report(DateTime.current.to_date, [true,true,true,false].sample, ["sample_one.jpg","sample_two.jpg","sample_three.jpg"].sample)
            puts("Successfully created a test report for patient #{patient.id}")
        end

      end
    else
        puts("This worker does not run in production environments")
    end
  end
end
