class NotifyPatient
  def initialize(patient)
    @patient = patient
  end

  def medication_reminder
    use_patient_locale do
      PushNotificationSender.send(
        @patient,
        I18n.t("medication_reminder"),
        I18n.t("medication_reminder_body"),
        "/home",
        "MedicationReminder",
        [
          {
            action: "good",
            title: "👍 #{I18n.t("yes")}",
          },
          {
            action: "issue",
            title: "💬 #{I18n.t("no")}",
          },
        ]
      )
    end
  end

  def missed_three_days_reminder
    use_patient_locale do
      PushNotificationSender.send(
        @patient,
        I18n.t("missed_reporting_notifications.three_days.title"),
        I18n.t("missed_reporting_notifications.three_days.body"),
        "/missing-reporting/3",
        "MissedReportingReminder"
      )
    end
  end

  def missed_seven_days_reminder
    use_patient_locale do
      PushNotificationSender.send(
        @patient,
        I18n.t("missed_reporting_notifications.seven_days.title"),
        I18n.t("missed_reporting_notifications.seven_days.body"),
        "/missing-reporting/7",
        "MissedReportingReminder"
      )
    end
  end

  def missed_thirty_days_reminder
    use_patient_locale do
      PushNotificationSender.send(
        @patient,
        I18n.t("missed_reporting_notifications.thirty_days.title"),
        I18n.t("missed_reporting_notifications.thirty_days.body"),
        "/missing-reporting/30",
        "MissedReportingReminder"
      )
    end
  end


  def method_missing(name, *args, &block)
    puts("in method missing")
  end

  private

  def use_patient_locale
    I18n.with_locale(@patient.locale) do
      yield
    end
  end
end
