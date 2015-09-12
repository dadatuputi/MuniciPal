require 'rubygems'
require 'plivo'
include Plivo

AUTH_ID = "MANJYWOTGZN2UZN2VKZG"
AUTH_TOKEN = "NGE0NDRmNDcyMWIyZWY4ZTY1Y2NiOWEwZGRlYjNi"
FROM_NUMBER = "13306806866"

class TextMessagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    # TODO: process whatever params come from the service to get :phone_number and :text
    puts params
    from = params["From"]
    to = params["To"]
    text = params["Text"]

    if text.casecmp "Marco"

    else
      reply = self.send(to, "Polo")
    end
      reply = self.send(to, text)
    puts reply
  end

  def send(to, text)
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
    return response
  end

  def report
    # TODO handle report callbacks
    puts params
  end
end
