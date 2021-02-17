require "sidekiq-scheduler"

class TestReportsWorker
  include Sidekiq::Worker

  sidekiq_options retry: 0

  def perform()
    #Ensure that this will only run when the environment = development
    if (Rails.env.development?)
      ActiveRecord::Base.transaction do
        #Relevant test accounts
        accounts = Patient.where(id: [100, 101, 102])
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
