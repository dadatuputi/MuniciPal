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
    sms = SMS.new(params["To"], params["From"], params["Text"])
    return head :bad_request if !sms.valid?

    # Send message off to get handled
    sms_controller(sms)
    head :ok
  end

  def report
    # TODO handle report callbacks
    head :ok
  end

  def callback
    # TODO callback with overview message
  end

  # HELPER FUNCTIONS
  def sms_controller(sms)
    # TODO Identify State
    state = nil
    #suzy = Person.find_by(phone_number: phone_number)
    #suzy.name

    # Get Command from message
    words = sms.text.split
    words.nil? ? firstword="HELP" : firstword = words[0]
    # Route commands
    case firstword
    when "HELLO".downcase
      text = sms_command_hello
    when "HELP".downcase
      text = sms_command_help
    when "STOP".downcase
      text = sms_command_stop
    when "STATUS".downcase
      text = sms_command_status
    when "CALLME".downcase
      text = sms_command_callme(sms, state)
    else
      firstword = firstword[0,6].concat("...") if firstword.length > 10
      text = sms_command_help("#{firstword} is an unknown command.\n\n")
    end

    # Send response
    byebug if Rails.env.development?
    sms_to_send = SMS.new(sms.from, sms.to, text)
    sms_send(sms_to_send) if sms_to_send.valid?
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
    message.concat(HELLO_WELCOME)
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
    messageif (state.)
  end

  def sms_send(sms)
    p = RestAPI.new(AUTH_ID, AUTH_TOKEN)

    # Send SMS
    params = {
      'src' => sms.from,
      'dst' => sms.to,
      'text' => sms.text,
      'type' => 'sms',
      'url' => 'https://municipal-app.herokuapp.com/texts/report', # The URL to which with the status of the message is sent
      'method' => 'POST' # The method used to call the url
    }

    response = p.send_message(params)
    response
  end


  def sms_command_callme(sms, state)
    if state.nil?
      return ""
    else
      p = RestAPI.new(AUTH_ID, AUTH_TOKEN)

      params = {
          'to' => sms.from, # The phone number to which the call has to be placed
          'from' => sms.to, # The phone number to be used as the caller id
          'answer_url' => 'https://municipal-app.herokuapp.com/texts/callback', # The URL invoked by Plivo when the outbound call is answered
          'answer_method' => 'GET', # The method used to call the answer_url
          # Example for Asynchrnous request
          #'callback_url' => "https://enigmatic-cove-3140.herokuapp.com/callback", # The URL notified by the API response is available and to which the response is sent.
          #'callback_method' => "GET" # The method used to notify the callback_url.
      }

      # Make an outbound call
      response = p.make_call(params)
    end
  end

  ## STATIC STRINGS
  APP_NAME = "MuniciPal".freeze
  COMMANDS = {
    "HELLO" => "Start the walkthrough.",
    "HELP" => "This text.",
    "STOP" => "Stop receiving ".concat(APP_NAME).concat(" messages."),
    "STATUS" => "Check your status.",
    "CALLME" => "Call you back with citation status."
  }.freeze
  HELLO_WELCOME = "Welcome to #{APP_NAME}\n\nTo get started send us a citation number or drivers license number."
  STOP_RESPONSE = "You will no longer receive messages from #{APP_NAME}"
  STATUS_NONE = "You haven't started a session. Say HELLO to begin walkthrough."


end
