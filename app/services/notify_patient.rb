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
    send_notification({
      :title_key => "missed_reporting_notifications.three_days.title",
      :body_key => "missed_reporting_notifications.three_days.body",
      :url => "/missing-reporting/3",
      :type => "MissedReportingReminder",
    })
  end

  def missed_seven_days_reminder
    send_notification({
      :title_key => "missed_reporting_notifications.seven_days.title",
      :body_key => "missed_reporting_notifications.seven_days.body",
      :url => "/missing-reporting/7",
      :type => "MissedReportingReminder",
    })
  end

  def missed_thirty_days_reminder
    send_notification({
      :title_key => "missed_reporting_notifications.thirty_days.title",
      :body_key => "missed_reporting_notifications.thirty_days.body",
      :url => "/missing-reporting/30",
      :type => "MissedReportingReminder",
    })
  end

  def photo_day_reminder_one
    send_notification({
      :title_key => "photo_reminder.first.title",
      :body_key => "photo_reminder.first.body",
      :url => "/home",
      :type => "TestStripReminder",
    })
  end

  def photo_day_reminder_two
    send_notification({
      :title_key => "photo_reminder.second.title",
      :body_key => "photo_reminder.second.body",
      :url => "/home",
      :type => "TestStripReminder",
    })
  end

  private

  def send_notification(notification)
    # notification -> title_translation_key,body_translation_key,url,type
    use_patient_locale do
      PushNotificationSender.send(
        @patient,
        I18n.t(notification[:title_key]),
        I18n.t(notification[:body_key]),
        notification[:url],
        notification[:type]
      )
    end
  end

  def use_patient_locale
    I18n.with_locale(@patient.locale) do
      yield
    end
  end
end
