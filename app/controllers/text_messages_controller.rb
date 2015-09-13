require 'rubygems'
require 'plivo'
include Plivo

AUTH_ID = "MANJYWOTGZN2UZN2VKZG"
AUTH_TOKEN = "NGE0NDRmNDcyMWIyZWY4ZTY1Y2NiOWEwZGRlYjNi"
FROM_NUMBER = "13306806866"

class TextMessagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def send_reminder
    number = params[:number].gsub(/\s*/, "")
    number = "1#{number}" unless number.length == 11

    citation = Citation.find params[:citation_id]
    court = citation.court
    sms_send SMS.new(number, FROM_NUMBER, "Friendly reminder! You are due in court at #{court.name} tomorrow with regard to citation ##{citation.citation_number}")

    response = {ok: "true", message: "You have successfully signed up for a reminder!"}
    render json: response
  end

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
    # Get Command from message
    words = sms.text.split
    words.nil? ? firstword="HELP" : firstword = words[0]

    # Identify user
    byebug if Rails.env.development?
    user = Person.file_by(phone_number: sms.from)

    # State Machine
    if user.nil?
      # Anon state
      case firstword
      when "HELP".downcase
        text = sms_command_help("", user)
      when "HELLO".downcase
        text = sms_command_hello(user)
      when "STOP".downcase
        text = sms_command_stop(user)
      else
        firstword = firstword[0,6].concat("...") if firstword.length > 10
        message = "#{firstword}".concat(COMMAND_UNKNOWN).concat("\n\n")
        text = sms_command_help(message, user)
      end
    else
      # Auth state
      case firstword
      when "HELP".downcase
        text = sms_command_help("", user)
      when "HELLO".downcase
        text = sms_command_hello(user)
      when "STOP".downcase
        text = sms_command_stop(user)
      when "LIST".downcase
        text = sms_command_list(user)
      when "DETAIL".downcase
        text = sms_command_detail("", user, words)
      when "CALLME".downcase
        text = sms_command_callme(sms, user, words)
      else
        firstword = firstword[0,6].concat("...") if firstword.length > 10
        message = "#{firstword}".concat(COMMAND_UNKNOWN).concat("\n\n")
        text = sms_command_help(message, user)
      end
    end

    # Send response
    byebug if Rails.env.development?
    sms_to_send = SMS.new(sms.from, sms.to, text)
    sms_send(sms_to_send) if sms_to_send.valid?
  end

  # COMMAND FUNCTIONS
  def sms_command_help(message="", user)
    # Build Help Output
    message.concat("Available commands:\n")

    if user.nil?
      commands = COMMANDS_ANON
    else
      commands = COMMANDS_AUTH
    end

    COMMANDS_ANON.each {|command, description| message.concat("#{command}: #{description}\n") }

    message
  end

  def sms_command_hello(user)
    # Restart walkthrough
    user_stop(user) if !user.nil?

    HELLO_WELCOME
  end

  def sms_command_stop(user)
    # Stop tracking user
    user_stop(user) if !user.nil?

    STOP_RESPONSE
  end

  def sms_command_list(user)
    # List all citations
    citations = citations_sort(user)

    if (citations.count < 1)
      # No citations. Show messages
       return LIST_EMPTY
    elsif (citations.count = 1)
      # One citation. Show detail
      sms_command_detail(LIST_ONE, user, nil)
    else
      # Many citations. Show list
      message = ""
      # Iterate through each citation
      citations.each_with_index do |citation, index|
        warrant = false
        # Go through each citation and if one has a warrant, set flag
        citation.violations.each do |violation|
          warrant = violation.warrant?
        end
        # Generate lines
        message.concat("#{index}:")
        message.concat(" #{WARRANT_FLAG}") if warrant
        message.concat(" #{citation.citation_number}")
        message.concat(" #{citation.citation_date}")
      end
    end

    message
  end

  def sms_command_detail(message = "", user, words)
    citation = nil

    if  words.nil?
      # Words is nil when we only have a single citation
      citation = user.citations.first
    elsif words.length > 0 && words[1].to_i(10) > 10
      # Make sure we have a valid number
      number = words[1].to_i(10)
      citations = citations_sort(user)
      citation = citations[number] if number < citations.length && number >= 0
    end
    byebug if Rails.env.development?
or
      message.concat(DETAIL_INVALID).concat(citations.length-1)
    else
      # Let's give the people what they want
      # Build violations first
      warrant = false
      violations = ""
      # Go through each citation and if one has a warrant, set flag
      citation.violations.each_with_index do |violation, index|
        warrant = violation.warrant?
        violations.concat(VIOLATION_SHORT).concat(index).concat(": ")
        violations.concat(WARRANT_FLAG_SHORT).concat(" ")
        description = violation.violation_description[0,11].concat("...") if violation.violation_description.length > 15
        violations.concat(description).concat(" ")
        unless violation.fine_amount.nil?
          violations.concat(violation.fine_amount).concat(" ").concat(FINE_SHORT).concat(" ")
          unless violation.court_amount.nil?
            violations.concat(violation.court_amount).concat(" ").concat(FINE_SHORT).concat(" ")
          end
        end
        violations.concat("\n")
      end

      # Put details all together.
      message.concat(WARRANT_FLAG).concat("\n") if warrant
      message.concat(CITATION_SHORT).conctat(citation.citation_number).concat(":").concat()
      message.concat("-").concat(citation.status_date) unless citation.status_date.nil
      message
    end
  end

  def citations_sort(user)
    citations = user.citations
    citations.sort { |a,b| a.violations.any? { |violation| if violation.warrant? 1 else 0 end } - b.violations.any? { |violation| if violation.warrant? 1 else 0 end }}
    return citations
  end

  def sms_send(sms)
    byebug if Rails.env.development?
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
    puts "\e[33m[sms:send] #{params.inspect}\e[0m"

    response = p.send_message(params)
    response
  end


  def sms_command_callme(sms, user)
    if user.nil?
      return ""
    else
      p = RestAPI.new(AUTH_ID, AUTH_TOKEN)

      params = {
      response = p.make_call(para        firstword = firstword[0,6].concat("...") if firstword.length > 10
ms)
    end      when "STATUS".downcase
        text = sms_command_status(user)
      if !user.nil?
        user.phone_number = nil
        user.save
      end
    end
  end

  ## STATIC STRINGS
  APP_NAME = "MuniciPal".freeze
  COMMANDS_ANON = {
    "HELP" => "List commands.",
    "HELLO" => "Start walkthrough.",
    "STOP" => "Stop receiving ".concat(APP_NAME).concat(" msgs & close session."),
  }.freeze
  COMMANDS_AUTH = {
    "HELP" => "List commands.",
    "HELLO" => "Restart walkthrough.",
    "STOP" => "Stop receiving ".concat(APP_NAME).concat(" msgs."),
    "LIST" => "List citations.",
    "DETAIL #" => "Show details",
    "COURT #" => "Show court details",
    "CALLME" => "Call you back with info.",
  }.freeze
  HELLO_WELCOME = "Welcome to #{APP_NAME}\n\nTo get started, send us a citation number or drivers license number."
  STOP_RESPONSE = "You will no longer receive messages from #{APP_NAME}"
  STATUS_NONE = "You haven't started a session. Say HELLO to begin walkthrough."
  LIST_EMPTY = "No known citations."
  LIST_ONE = "One citation. Showing details:\n"
  WARRANT_FLAG = "!WARRANT!"
  WARRANT_FLAG_SHORT = "!W!"
  DETAIL_INVALID = "Please enter a valid citation number.\n\nFor example, send DETAIL "
  VIOLATION_SHORT = "V"
  CITATION_SHORT = "C"
  FINE_SHORT = "(f)"
  FINE_COURT_SHORT = "(c)"
  COMMAND_UNKNOWN = " is an unknown command."

end
