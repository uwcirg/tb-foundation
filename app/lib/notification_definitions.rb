class NotificationDefinitions
  def self.method_missing(m, *args, &block)
    if NOTIFICATION_DEFINITIONS.include?(m.to_sym)
      return NOTIFICATION_DEFINITIONS[m.to_sym]
    else
      raise ArgumentError.new("Notification type `#{m}` doesn't exist.")
    end
  end

  NOTIFICATION_DEFINITIONS = {

    :medication_reminder => {
      :title_key => "medication_reminder.title",
      :body_key => "medication_reminder.body",
      :url => "/home",
      :type => "MedicationReminder",
      :actions => [
        {
          action: "good",
          title_key: "medication_reminder.yes_action"
        },
        {
          action: "issue",
          title_key: "medication_reminder.no_action",
        },
      ],
    },
    :missed_three_days_reminder => {
      :title_key => "missed_reporting_notifications.three_days.title",
      :body_key => "missed_reporting_notifications.three_days.body",
      :url => "/missing-reporting/3",
      :type => "MissedReportingReminder",
    },
    :missed_seven_days_reminder => {
      :title_key => "missed_reporting_notifications.seven_days.title",
      :body_key => "missed_reporting_notifications.seven_days.body",
      :url => "/missing-reporting/7",
      :type => "MissedReportingReminder",
    },

    :missed_thirty_days_reminder => {
      :title_key => "missed_reporting_notifications.thirty_days.title",
      :body_key => "missed_reporting_notifications.thirty_days.body",
      :url => "/missing-reporting/30",
      :type => "MissedReportingReminder",
    },
    :photo_reminder_one => {
      :title_key => "photo_reminder.first.title",
      :body_key => "photo_reminder.first.body",
      :url => "/home",
      :type => "TestStripReminder",
    },
    :photo_reminder_two => {
      :title_key => "photo_reminder.second.title",
      :body_key => "photo_reminder.second.body",
      :url => "/home",
      :type => "TestStripReminder",
    },
    :redo_photo => {
        :title_key => "redo_photo.title",
        :body_key => "redo_photo.body",
        :url => "/redo-photo",
        :type =>  "RedoPhoto"
    },
    :severe_symptom_alert => {
      :title_key => "severe_symptom.title",
      :body_key => "severe_symptom.body",
      :url => "/home/needs-review",
      :type =>  "SevereSymptom"
    },
    :provider_new_message => {
      :title_key => "new_message_private_provider.title",
      :body_key => "new_message_private_provider.body",
      :url => "/messaging",
      :type =>  "Messaging"
    }
  }
end
