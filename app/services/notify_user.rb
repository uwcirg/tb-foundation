class NotifyUser
  def initialize(patient)
    @patient = patient
  end

  def private_message_alert(channel_id)
    use_patient_locale do
      PushNotificationSender.send(
        @patient,
        I18n.t("new_message_private.title"),
        I18n.t("new_message_private.body"),
        "/messaging/channel/#{channel_id}",
        "Messaging"
      )
    end
  end

  def public_message_alert(channel_name, channel_id)
    use_patient_locale do
      PushNotificationSender.send(
        @patient,
        "#{I18n.t("new_message_public.title_partial")} #{channel_name}",
        I18n.t("new_message_public.body"),
        "/messaging/channel/#{channel_id}",
        "Messaging"
      )
    end
  end

  #Default to statically defined notifications when the text does not need to be personalized
  def method_missing(m, *args, &block)
    use_patient_locale do
      send_notification(NotificationDefinitions.send(m))
    end
  end

  private

  def send_notification(notification)
    relevant_actions = notification.key?(:actions) ? notification[:actions].map {
      |og|
      { action: og[:action], title: I18n.t(og[:title_key]) }
    } : nil

    use_patient_locale do
      PushNotificationSender.send(
        @patient,
        I18n.t(notification[:title_key]),
        I18n.t(notification[:body_key]),
        notification[:url],
        notification[:type],
        relevant_actions
      )
    end
  end

  def use_patient_locale
    I18n.with_locale(@patient.locale) do
      yield
    end
  end
end
