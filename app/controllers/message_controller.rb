class MessageController < AuthenticatedController
  #before_action :auth_any_user, :except => [:cors_preflight]
  before_action :auth_any_user
  skip_before_action :verify_authenticity_token

  #Message CRUG
  def post_message
    render( json: {hello: "message"}, status: 200)
  end

  def edit_message
    #Params messageID, body, dateTime

  end

  def send_message

  end

  #Coordinator / Person that posted message only
  def delete_message

  end




end