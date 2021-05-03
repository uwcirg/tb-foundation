class PushNotificationStatus < ApplicationRecord
    enum notification_type: { Default: 0, Messaging: 1, MedicationReminder: 2, TestStripReminder: 3, AppointmentReminder: 4 }
    belongs_to :user
end
