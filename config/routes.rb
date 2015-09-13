Rails.application.routes.draw do

  # --------------------------------------------------------------------------- #
  # The Web application                                                         #
  # --------------------------------------------------------------------------- #

  root "walkthrough#index"

  scope "walkthrough" do
    get "court/:id" => "walkthrough#court", as: :court
    get "citation/:id"=> "walkthrough#citation", as: :citation
    get "person/:id" => "walkthrough#person", as: :person
    post "search" => "walkthrough#search"
    post "confirm_birthday" => "walkthrough#confirm_birthday"
  end

  get "help/attorneys" => "walkthrough#find_attorneys"
  get "help/community-service" => "walkthrough#community_service"



  # --------------------------------------------------------------------------- #
  # The SMS API                                                                 #
  # --------------------------------------------------------------------------- #

  post "texts/incoming" => "text_messages#receive"
  post "texts/report" => "text_messages#report"
  get "texts/callback" => "text_messages#callback"
  post "texts/callback" => "text_messages#callback"
  post "texts/send_reminder" => "text_messages#send_reminder"
  get "geodata/muny" => "geo_data#municipalities"

end
