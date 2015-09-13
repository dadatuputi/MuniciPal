Rails.application.routes.draw do

  root 'walkthrough#index'

  post "texts/incoming" => "text_messages#receive"
  post "texts/report" => "text_messages#report"
  get "texts/callback" => "text_messages#callback"
  post "texts/callback" => "text_messages#callback"
  post "texts/send_reminder" => "text_messages#send_reminder"
  get "geodata/muny" => "geo_data#municipalities"
  post "court/feedback" => "court#feedback"

  get "help/attorneys" => "walkthrough#find_attorneys"
  get "help/community-service" => "walkthrough#community_service"

  scope "walkthrough" do
    get 'court/:id' => "walkthrough#court", as: :court
    get 'citation/:id'=> "walkthrough#citation", as: :citation
    get 'person/:id' => "walkthrough#person", as: :person
    post "search" => "walkthrough#search"
  end

end
