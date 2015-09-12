require 'rubygems'
require 'plivo'
include Plivo

AUTH_ID = "MANJYWOTGZN2UZN2VKZG"
AUTH_TOKEN = "NGE0NDRmNDcyMWIyZWY4ZTY1Y2NiOWEwZGRlYjNi"
FROM_NUMBER = "13306806866"

class TextMessagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    byebug if Rails.env.development?
    sms = SMS.new(params)
    return head :bad_request if !sms.valid?

    # Send message off to get handled
    sms_controller(sms)
    head :ok
  end

  def report
    # TODO handle report callbacks
    head :ok
  end

  # HELPER FUNCTIONS
  def sms_controller(sms)
    # Get Command from message
    words = sms.text.split
    words.nil? ? firstword="HELP" : firstword = words[0]

    # Route commands
    case firstword
    when "HELLO".downcase
      sms_command_hello
    when "HELP".downcase
      sms_command_help
    when "STOP".downcase
      sms_command_stop
    when "STATUS".downcase
      sms_command_status
    else
      sms_command_help("Unknown command.\n\n")
    end

    # TODO Identify State


  end

  # COMMAND FUNCTIONS
  def sms_command_help(message="")
    # Build Help Output
    message.concat("Available commands:\n")
    COMMANDS.each {|command, description| message.concat("#{command}: #{description}\n") }
    message
  end

  def sms_command_hello(message="")
    # TODO Build Hello response - use guide
    message.concat(WELCOME)
    message
  end

  def sms_command_stop(message="")
    # TODO Stop tracking user
    message.concat(STOP_RESPONSE)
    message
  end

  def sms_command_status(message="")
    # TODO Show current user's status
    message.concat(STATUS_NONE)
    message
  end

  def sms_send(sms)
    p = RestAPI.new(AUTH_ID, AUTH_TOKEN)

    # Send SMS
    params = {
      'src' => FROM_NUMBER,
      'dst' => to,
      'text' => text,
      'type' => 'sms',
      'url' => 'https://municipal-app.herokuapp.com/texts/report', # The URL to which with the status of the message is sent
      'method' => 'POST' # The method used to call the url
    }

    response = p.send_message(params)
    response
  end




  ## STATIC STRINGS
  APP_NAME = "MuniciPal".freeze
  COMMANDS = {
    "HELLO" => "description",
    "HELP" => "This text.",
    "STOP" => "Stop receiving ".concat(APP_NAME).concat(" messages."),
    "STATUS" => "Check your status."
  }.freeze
  WELCOME = "Welcome to #{APP_NAME}\n\nTo get started send us your citation number or drivers license number."
  STOP_RESPONSE = "You will no longer receive messages from #{APP_NAME}"
  STATUS_NONE = "You haven't started with #{APP_NAME} yet. Send HELLO to begin."


end
