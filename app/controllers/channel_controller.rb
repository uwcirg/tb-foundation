class ChannelController < AuthenticatedController

    #before_action :auth_any_user, :except => [:cors_preflight]
    before_action :auth_any_user
    skip_before_action :verify_authenticity_token
  
    #Message CRUG
    def new_channel
        #chan = Channel.create!(title: params[:title], subtitle: params[:subtitle], creator_id: @current_user.uuid, creator_type: "Participant")
        chan = @current_user.channels.create!(title: params[:title],subtitle: params[:subtitle])
        render(json: chan.to_json, status: 200)
    end

    def all_channels
        response = Channel.all().sort_by &:created_at
        render(json: response.to_json, status: 200)
    end

    def post_message
        newMessage = @current_user.messages.create!(body: params[:body],channel_id: params["channelID"],creator_id: @current_user.uuid)
        @current_user.testd
        render(json: newMessage.to_json , status: 200)
    end

    def get_recent_messages
        messages = Channel.find(params["channelID"]).messages.order("created_at DESC")
        render(json: messages.to_json , status: 200)
    end

    def get_messages_before
        messages = Channel.find(params["channelID"]).messages.where("id < ?", params["messageID"])
        render(json: messages.to_json , status: 200)
    end
  
  end