class Channel::ChannelsController < UserController

    before_action :snake_case_params

    def index
        auth_user
        render(json: @current_user.available_channels, status: :ok)
    end 

    def create
        auth_practitioner
        channel = Channel.create(new_channel_params.merge(user_id: @current_practitoner.id))
        attempt_save_and_render(channel)
    end

    private

    def attempt_save_and_render(channel)
        if(channel.save)
            render(json: channel, status: 200)
        else
            errors = handle_errors
            render(json: { error: 422, paramErrors: errors }, status: 422)
        end
    end

    def new_channel_params
        params.permit(:title,:subtitle)
    end

    def handle_errors(object)
        @errors = object.as_json.deep_transform_keys! { |key| key.camelize(:lower) }
    end





  end
  