class NotifyUser
  def initialize(user)
    @user = user
  end

  # def severe_symptom_alert(patient_id)
  #   with_user_locale do
  #     PushNotificationSender.send(
  #       @user,
  #       "Severe Symptom Reported",
  #       "James reported a severe symptom, click here to view more information",
  #       "/patients/#{patient_id}}",
  #       "SevereSymptom"
  #     )
  #   end
  # end

  def private_message_alert(channel_id)
    with_user_locale do
      PushNotificationSender.send(
        @user,
        I18n.t("new_message_private.title"),
        I18n.t("new_message_private.body"),
        "/messaging/channel/#{channel_id}",
        "Messaging"
      )
    end
  end

  def public_message_alert(channel_name, channel_id)
    with_user_locale do
      PushNotificationSender.send(
        @user,
        "#{I18n.t("new_message_public.title_partial")} #{channel_name}",
        I18n.t("new_message_public.body"),
        "/messaging/channel/#{channel_id}",
        "Messaging"
      )
    end
  end

  #Default to statically defined notifications when the text does not need to be personalized
  def method_missing(m, *args, &block)
    with_user_locale do
      send_notification(NotificationDefinitions.send(m))
    end
  end

  private

  def send_notification(notification)
    relevant_actions = notification.key?(:actions) ? notification[:actions].map {
      |og|
      { action: og[:action], title: I18n.t(og[:title_key]) }
    } : nil

    with_user_locale do
      PushNotificationSender.send(
        @user,
        I18n.t(notification[:title_key]),
        I18n.t(notification[:body_key]),
        notification[:url],
        notification[:type],
        relevant_actions
      )
    end
  end

  def with_user_locale
    I18n.with_locale(@user.locale) do
      yield
    end
  end
end
