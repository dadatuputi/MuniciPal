class WalkthroughController < ApplicationController
  def index
    @citations = Citation.all
    @people = Person.all
    @courts = Court.all
  end

  def search
    if citation = Citation.find_by(citation_number: params[:q])
      response = {ok: "true", location: citation_path(citation)}

    elsif person = Person.find_by(drivers_license_number: params[:q])
      case person.citations.count
      when 0 then response = {ok: "false", message: "You have no citations"}
      when 1 then response = {ok: "true", location: citation_path(person)}
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
  end

  def citation
    @citation = Citation.find params[:id]
    @person = @citation.person
    @other_citations = @person.citations.where.not(id: @citation.id)
  end

end
