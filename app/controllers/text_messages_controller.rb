require 'rubygems'
require 'plivo'
include Plivo
include ActionView::Helpers::NumberHelper

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
    r = Response.new()

    # Build Body
    phone_number = params["To"]
    user = Person.find_by(phone_number: phone_number)

    unless user.nil?
      # English Text
      body1 = "Welcome to ").concat(APP_NAME).concat(", ").concat(user.first_name).concat(" ").concat(user.last_name)
      # Warrant
      citations = user.citations
      warrant = has_warrant(user)
      body2 = ""
      body2.concat("Attention! You have an arrest warrant issued to you Please call 800-200-1337 for free, anonymous assistance in resolving this issue") if warrant
      # Citations
      number_citations = 0
      number_citations = citations.length unless number_citations.nil?
      body3 = ""
      body3.concat("You have ").concat(number_citations.to_s).concat(" citations")
      body3.concat(WARRANT_HELP_BOILERPLATE_NO_DOT) if warrant

      params1 = {
          'language'=> "en-GB",
          'voice' => "WOMAN"
      }
      r.addSpeak(body1, params1)
      r.addSpeak(body2, params1)
      r.addSpeak(body3, params1)
    end



    # French Text
    #body2 = 'Ce texte généré aléatoirement peut-être utilisé dans vos maquettes'
    #params2 = {
    #    'language' => "fr-FR"
    #}

    #r.addSpeak(body2, params2)

    render xml: r.to_s
    #render text: r.to_s, content_type: :xml
    #render r.to_s, content_type: "text/xml"
    #puts r.to_xml()
    #content_type 'text/xml'
    #return r.to_s()
  end

  # HELPER FUNCTIONS
  def sms_controller(sms)
    # Get Command from message
    words = sms.text.split
    words.nil? ? firstword="HELP" : firstword = words[0]

    # Identify user
    user = Person.find_by(phone_number: sms.from.to_s)
    #Q526993883
    byebug if Rails.env.development?

    # State Machine
    if user.nil?
      # Anon state
      case firstword.downcase
      when "HELP".downcase
        text = sms_command_help
      when "HELLO".downcase
        text = sms_command_hello
      when "STOP".downcase
        text = sms_command_stop
      else
        # Try to look up user given provided data
        user = lookup_user(sms, words)

        if user.nil?
          # Bad command
          firstword = firstword[0,6].concat("...") if firstword.length > 10
          message = "#{firstword}".concat(COMMAND_UNKNOWN_ANON).concat("\n\n")
          text = sms_command_help(message, user)
        else
          # Found user!
          text = "Welcome #{user.first_name} #{user.last_name}.\n\n"
          text.concat(sms_command_list(user))
        end
      end
    else
      # Auth state
      case firstword.downcase
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
      when "COURT".downcase
        text = sms_command_court(user, words)
      when "CALLME".downcase
        text = sms_command_callme(sms)
      when "WARRANT".downcase
        text = sms_command_warrant(user)
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
  def sms_command_help(message="", user=nil)
    # Build Help Output
    message.concat("Available commands:\n")

    if user.nil?
      commands = COMMANDS_ANON
    else
      commands = COMMANDS_AUTH
    end

    commands.each {|command, description| message.concat("#{command}: #{description}\n") }

    message
  end

  def sms_command_hello(user=nil)
    # Restart walkthrough
    user_stop(user) if !user.nil?

    HELLO_WELCOME
  end

  def sms_command_stop(user=nil)
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
    elsif (citations.count == 1)
      # One citation. Show detail
      return sms_command_detail(LIST_ONE, user, nil)
    else
      # Many citations. Show list

      # Build Citation List First
      citation_message = ""
      warrant_overall = false
      # Iterate through each citation
      citations.each_with_index do |citation, index|
        warrant = false
        # Go through each citation and if one has a warrant, set flag
        citation.violations.each do |violation|
          if violation.warrant?
            warrant = true
            warrant_overall = true
          end
        end
        # Generate lines
        citation_message.concat("#{index+1}:")
        citation_message.concat(" #{WARRANT_FLAG_SHORT}") if warrant
        citation_message.concat(" #{citation.citation_number}")
        citation_message.concat(" #{citation.citation_date}")
        citation_message.concat("\n")
      end

      message = ""
      message.concat(WARRANT_FLAG).concat("\n") if warrant_overall
      citations.length > 1? message.concat("Open Citations:\n\n") : message.concat("Open Citation:\n\n")
      message.concat(citation_message)
    end

    message
  end

  def sms_command_detail(message = "", user, words)
    citation = lookup_citation(user, words)

    unless citation.nil?
      # Let's give the people what they want
      # Build violations first
      warrant = false
      violations = ""
      # Go through each citation and if one has a warrant, set flag
      citation.violations.each_with_index do |violation, index|
        warrant = violation.warrant?
        violations.concat(VIOLATION_SHORT).concat((index+1).to_s).concat(": ")
        violations.concat(WARRANT_FLAG_SHORT).concat(" ") if warrant
        description = violation.violation_description[0,29].concat("...") if violation.violation_description.length > 30
        violations.concat(description).concat(" ")
        unless violation.fine_amount.nil?
          violations.concat(number_to_currency(violation.fine_amount)).concat(FINE_SHORT).concat(" ")
          unless violation.court_cost.nil?
            violations.concat(number_to_currency(violation.court_cost)).concat(FINE_COURT_SHORT).concat(" ")
          end
        end
        violations.concat("\n")
      end

      # Put details all together.
      message.concat(WARRANT_FLAG).concat("\n") if warrant
      message.concat(CITATION_LONG).concat(" ").concat(citation.citation_number).concat(":")
      message.concat("-").concat(citation.citation_date.to_s) unless citation.citation_date.nil?
      message.concat("\n\n").concat(violations)
      message
    else
      return message.concat(DETAIL_INVALID).concat("1")
    end
  end

  def sms_command_court(user, words)
    citation = lookup_citation(user, words)
    court = nil
    court = citation.court unless citation.nil?
    message = ""

    unless court.nil?
      # Let's give the people what they want
      # Court Details
      message.concat("Court: ").concat(court.name).concat("\n\n")
      message.concat("Call: ").concat(court.phone_number).concat("\n") unless court.phone_number.nil?
      unless court.address.nil?
        message.concat(court.address) unless court.address.nil?
        unless court.zip_code.nil?
          message.concat(" ").concat(court.zip_code)
        end
        message.concat("\n")
      end
      message.concat("Pay Online? ").concat("Y:").concat(court.online_payment_provider).concat("\n") unless court.online_payment_provider.nil?
      message.concat("Website: ").concat(court.website) unless court.website.nil?
      message
    else
      return message.concat(DETAIL_INVALID).concat("1")
    end
  end

  def sms_command_callme(sms)
    p = RestAPI.new(AUTH_ID, AUTH_TOKEN)
    byebug if Rails.env.development?

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

  def sms_command_warrant(user)
    message = ""
    unless user.nil?
      if has_warrant(user)
        message.concat("You have a warrant issued for your arrest. ").concat(WARRANT_HELP_BOILERPLATE)
      else
        message.concat(WARRANT_HELP_HAS_NOT)
      end
    end
    message
  end

  def lookup_citation(user, words)
    citation = nil

    if  words.nil?
      # Words is nil when we only have a single citation
      citation = user.citations.first
    elsif words.length > 1 && words[1].to_i(10) > 0
      # Make sure we have a valid number
      number = words[1].to_i(10)
      citations = citations_sort(user)

      unless citations.nil? || number >= citations.length
        citation = citations[number-1]
      end
    end

    return citation
  end

  def lookup_user(sms, words)
    # First check for valid words
    return nil if words.nil? || words.length < 1

    user = nil
    byebug if Rails.env.development?

    if words[0].length == 10
      # Try driver's license
      user = Person.find_by(drivers_license_number: words[0])
    elsif user.nil? && words[0].length >= 6 && words[0].length <= 9
      # Try citation number
      citation = Citatation.find_by(citation_number: words[0])
      user = citation.person unless citation.nil?
    elsif user.nil?
      # Try name and date of birth
      return nil unless words[0].length >= 3

      # Search for user based on their supplied parameters
      user = Person.find_by(first_name: words[0], last_name: words[1], date_of_birth: words[2])
    end

    unless user.nil?
      # Put phone number in user
      user.phone_number = sms.from
      user.save
      return user
    end
  end

  def citations_sort(user)
    return user.citations
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

  def has_warrant(user)
    warrant = false
    unless user.nil?
      citations = user.citations
      unless citations.nil?
        citations.violations.each do |violation|
          if violation.warrant?
            warrant = true
          end
        end
      end
    end
    return warrant
  end

  def user_stop(user)
    if !user.nil?
        user.phone_number = nil
        user.save
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
    "WARRANT" => "Get warrant help.",
  }.freeze
  HELLO_WELCOME = "Welcome to #{APP_NAME}!\n\nTo get started, send a citation number, drivers license number or name and date of birth."
  STOP_RESPONSE = "You will no longer receive messages from #{APP_NAME}"
  STATUS_NONE = "You haven't started a session. Say HELLO to begin walkthrough."
  LIST_EMPTY = "No known citations."
  LIST_ONE = "One citation. Showing details:\n"
  WARRANT_FLAG = "!WARRANT!"
  WARRANT_FLAG_SHORT = "!W!"
  DETAIL_INVALID = "Please enter a valid citation number.\n\nFor example, send DETAIL "
  VIOLATION_SHORT = "V"
  CITATION_SHORT = "C"
  CITATION_LONG = "Citation"
  FINE_SHORT = "(f)"
  FINE_COURT_SHORT = "(c)"
  COMMAND_UNKNOWN = " is an unknown command."
  COMMAND_UNKNOWN_ANON = " is an unkown command, citation, license number or user."
  WARRANT_HELP_BOILERPLATE = "When you have a warrant, the police have been instructed to arrest and hold you in jail until you can appear in court.  The court might be willing to schedule a hearing or mitigate the jail time. Please call 800-200-1337 for free, anonymous assistance in resolving this issue."
  WARRANT_HELP_BOILERPLATE_NO_DOT = "When you have a warrant, the police have been instructed to arrest and hold you in jail until you can appear in court  The court might be willing to schedule a hearing or mitigate the jail time Please call 800-200-1337 for free, anonymous assistance in resolving this issue"
  WARRANT_HELP_HAS_NOT = "We can't find any warrants for you. " + WARRANT_HELP_BOILERPLATE

end
