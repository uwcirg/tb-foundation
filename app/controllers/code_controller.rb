require "json"
require "bcrypt"

# Run code.
#
# Just... run the code.
class CodeController < ApplicationController
  before_action :set_cors_headers, only: [:evaluate, :cors_preflight]
  skip_before_action :verify_authenticity_token

  def evaluate
    code = params.permit(:code)[:code]

    # This seems to be as good a place as any to leave a note about consequences.

    # Consequences are real,
    # and every action has a consequence.

    # Code - code is not real.
    # Code is an invention,
    # magical and captivating in its nature,
    # that lets us convey an enormous depth of meaning.

    # And yet,
    # certain people listen to what code does,
    # and certain real effects have been tied,
    # for better or worse,
    # to the machinations of software.

    # I do not like the vocabulary that we have today,
    # with its notion of "executing" software.
    # Software does not execute,
    # nor should it.

    # Troublesome also is the language about "evaluating" software.
    # I would wish anyone good luck
    # who is charged the task of giving a proper logical evaluation
    # of this system we're building.

    convey(results_of_executing(code))
  end

  def cors_preflight
    render plain: "", status: 200
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
    logger.tagged("information.conveyed") { logger.info information.to_json }

    render json: information
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
