require "webpush"

class PushNotificationSender

  # Allow calling the send method without creating a new object - more information https://www.toptal.com/ruby-on-rails/rails-service-objects-tutorial
  def self.send(*args, &block)
    new(*args, &block).send
  end

  def initialize(user, title, body, app_url, type, actions = nil)
    @user = user
    @title = title
    @body = body
    @app_url = app_url
    @type = type
    @actions = actions
    @status = PushNotificationStatus.create!(user: @user, notification_type: type)
  end

  def send_notification
    return if user_missing_required_information?

    begin
      send_web_push
    rescue => exception
      return
    end

    @status.update!(sent_successfully: true)
  end

  def send
    send_notification
  end

  private

  def user_missing_required_information?
    return @user.push_url.nil? || @user.push_auth.nil? || @user.push_p256dh.nil?
  end

  def message_body
    return JSON.generate(
             title: "#{@title}",
             body: "#{@body}",
             url: "#{ENV["URL_CLIENT"]}",
             data: { url: @app_url, id: @status.id, type: @status.notification_type },
             actions: @actions,
           )
  end

  def send_web_push
    Webpush.payload_send(
      message: message_body,
      endpoint: @user.push_url,
      p256dh: @user.push_p256dh,
      auth: @user.push_auth,
      ttl: 24 * 60 * 60,
      vapid: {
        subject: "mailto:sender@example.com",
        public_key: ENV["VAPID_PUBLIC_KEY"],
        private_key: ENV["VAPID_PRIVATE_KEY"],
      },
    )
  end
end
