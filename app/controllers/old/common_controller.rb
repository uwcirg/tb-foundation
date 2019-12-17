require "json"
require "bcrypt"
require "securerandom"

class CommonController < AuthenticatedController
  #before_action :auth_any_user, :except => [:cors_preflight]
  before_action :auth_any_user
  skip_before_action :verify_authenticity_token

  def get_photo
    name = params[:filename]
    userID= params[:userID]

    photoDir = "/ruby/backend/upload/strip_photos/#{userID}"

    send_file "#{photoDir}/#{name}.png", type: 'image/png', disposition: 'inline'

  end


end