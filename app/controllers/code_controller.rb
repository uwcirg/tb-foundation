require "json"
require "bcrypt"
require "securerandom"
require "fileutils"

# Run code.
#
# Just... run the code.
class CodeController < ApplicationController
  before_action :set_cors_headers, only: [:evaluate, :cors_preflight]
  skip_before_action :verify_authenticity_token

  def evaluate
    code = params.permit(:code)[:code]

    convey(results_of_executing(code))
  end

  def add_photo 

    #Make sure directory for photos exists
    FileUtils.mkdir_p '/ruby/backend/upload/strip_photos/'


    name = params["filename"]
    picture = params["photo"]
    File.open("/ruby/backend/upload/strip_photos/#{name}.png", "wb") do |file|
    file.write(picture)
    end
  end

  def post_new_coordinator

    newCoordinator = Coordinator.new(
      name: params["name"],
      email: params["email"],
      password_digest:  BCrypt::Password.create(params["password"]),
      uuid: SecureRandom.uuid,
    )

    newCoordinator.save

    render(json: newCoordinator.to_json, status: 200)
  end

  def cors_preflight
    response.set_header("Allow", "POST")
    response.set_header("Access-Control-Allow-Origin", "*")
    response.set_header("Access-Control-Allow-Headers", "Content-Type") 
  end


  def get_all_strip_reports
      rows = StripReport.order("created_at DESC")
      render(json: rows.to_json, status: 200)
  end

  private

  def set_cors_headers
    response.set_header("Allow", "POST")
    response.set_header("Access-Control-Allow-Origin", "*")
    response.set_header("Access-Control-Allow-Headers", "Content-Type")
  end

  # Securely transport information to the public context
  # (in this case, a web client)
  def convey(information)
    # The function would first and foremost check that the information is "valid".
    # What this means in the general case is still uncertain,
    # but in our immediate case "valid" means a ruby Hash object,
    # with primitives for both its keys and values.

    # Make sure all conveyed information appears in the log
    # https://guides.rubyonrails.org/debugging_rails_applications.html#the-logger

    render json: information.to_json
  end

  # Primitives are always "valid",
  # and structures built of "valid" objects *tend* to be valid as well.
  def valid?(information)
    # Our understanding of "validity" will need to be tested.

  end

  def results_of_executing(code)
    eval(code)
  end

end
