class PushNotificationStatus < ApplicationRecord
    enum notification_type: { Default: 0, Messaging: 1, MedicationReminder: 2, 
        TestStripReminder: 3, AppointmentReminder: 4, MissedReportingReminder: 5, RedoPhoto: 6 }
    belongs_to :user
end
