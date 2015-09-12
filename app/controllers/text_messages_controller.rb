class TextMessagesController < ApplicationController
  
  def receive
    # TODO: process whatever params come from the service to get :phone_number and :text
    phone_number = :something
    text = :something
    reply = TextMessageInterface.reply_to(phone_number, text)
    # TODO: make an API call that will send :reply to :phone_number
  end
  
end
