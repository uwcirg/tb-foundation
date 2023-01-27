class EndOfTreatmentMessageWorker
  include Sidekiq::Worker

  def perform
    ending_treatment = Patient.where(treatment_end_date: Date.current + 1.week)

    ending_treatment.each do |patient|
      I18n.with_locale(patient.locale) do
        patient.send_automated_message_to_patient(I18n.t("end_treatment_message"))
      end
    end

    recently_finished = Patient.where("treatment_end_date <= ? AND treatment_end_date >= ?", Date.current, Date.current - 3.days)

    recently_finished.each do |patient|
      I18n.with_locale(patient.locale) do
        has_not_recieved_first_message = !patient.private_message_channel.messages.where(user_id: Administrator.first.id).exists?

        patient.send_automated_message_to_patient(I18n.t("end_treatment_message")) if has_not_recieved_first_message

        days_since_end = Date.current - patient.treatment_end_date
        translation_string = "end_treatment_photo_#{days_since_end}"

        patient.send_automated_message_to_patient(I18n.t(translation_string))
      end
    end
  end
end
