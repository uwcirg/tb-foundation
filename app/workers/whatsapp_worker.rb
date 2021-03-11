class WhatsappWorker
  include Sidekiq::Worker

  def perform(wa_number)
    account_sid = ENV["TWILIO_ID"]
    auth_token = ENV["TWILIO_TOKEN"]
    @client = Twilio::REST::Client.new(account_sid, auth_token)

    message = @client.messages.create(
      from: "whatsapp:#{ENV["TWILIO_WA_NUMBER"]}",
      body: "You have not reported your medication in 3 days. Please contact your coordinator if you are having issues using the app",
      to: "whatsapp:#{wa_number}",
    )

    puts message
  end
end
