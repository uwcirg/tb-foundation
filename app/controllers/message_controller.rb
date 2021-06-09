class MessageController < UserController
    before_action :auth_practitioner
    before_action :snake_case_params

    def update
        #Make sure that its not a private channel
        update_message_params = filter_params
        message = Message.find(update_message_params[:id])

        if(message.channel.is_private && !message.channel.is_site_channel)
            render(json: {error: "Cannot hide messages in non public discussions"}, status: 422)
            return
        end

        message.update!(update_message_params)
        render(json: message, status: :ok)
    end

    private

    def filter_params
        params.permit(:is_hidden,:id)
    end


end