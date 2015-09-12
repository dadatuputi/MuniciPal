class WalkthroughController < ApplicationController
  def index
    @citations = Citation.all
    @people = Person.all
    @courts = Court.all
  end

  def search
    if citation = Citation.find_by(citation_number: params[:q])
      redirect_to citation_path citation
    elsif person = Person.find_by(drivers_license_number: params[:q])
      case person.citations.count
      when 0 then redirect_to root_path, notice: "You have no citations"
      when 1 then redirect_to citation_path person.citations.first
      else        redirect_to person_path person
      end
    else
      # TODO: ajaxify these responses
      redirect_to root_path, notice: "You have no citations"
    end
  end

  def person
    @person = Person.find params[:id]
    @citations = @person.citations
  end

  def citation
    @citation = Citation.find params[:id]
    @court = @citation.court
    @person = @citation.person
    @other_citations = @person.citations.where.not(id: @citation.id)
    @today = Date.today
  end

end
