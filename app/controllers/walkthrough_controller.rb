class WalkthroughController < ApplicationController

  def index
    @courts = Court.all
  end

  def search
    if citation = Citation.find_by(citation_number: params[:q])
      response = {ok: "true", location: citation_path(citation)}
    elsif person = Person.find_by_name(params[:q])
      response = {ok: "validate", name: person.first_name, birthday: person.date_of_birth, id: person.id }
    elsif person = (params[:q] && Person.find_by(drivers_license_number: params[:q])) || Person.find_by(id: params[:id])
      case person.citations.count
      when 0 then response = {ok: "false", message: "You have no citations"}
      when 1 then response = {ok: "true", location: citation_path(person.citations.first)}
      else        response = {ok: "true", location: person_path(person)}
      end
    else
      response = {ok: "false", message: "You have no citations"}
    end
    render json: response
  end

  def person
    @person = Person.find params[:id]
    @citations = @person.citations
    @warrants = @citations.warrants
  end

  def citation
    @citation = Citation.find params[:id]
    @warrants = @citation.warrants
    @court = @citation.court
    @person = @citation.person
    @other_citations = @person.citations.where.not(id: @citation.id)
    @today = Date.today
  end

  def court
    @court = Court.find params[:id]
    @today = Date.today
    render action: :citation
  end

  def find_attorneys
  end

  def community_service
  end

end
