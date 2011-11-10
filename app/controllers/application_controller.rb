class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :require_login, :except => [:not_authenticated]

  helper_method :current_users_list


  def render_validation_error(code, message = nil)
    xml = Nokogiri::XML::Builder.new do |xml|
      xml.serviceResponse("xmlns:cas" => "http://www.yale.edu/tp/cas") {
        xml.parent.namespace = xml.parent.namespace_definitions.first
        xml['cas'].authenticationFailure(message, :code => code.to_s.upcase){
        }
      }
    end
    render :xml => xml.to_xml
  end

  def render_validation_success(username)
    xml = Nokogiri::XML::Builder.new do |xml|
      xml.serviceResponse("xmlns:cas" => "http://www.yale.edu/tp/cas") {
        xml.parent.namespace = xml.parent.namespace_definitions.first
        xml['cas'].authenticationSuccess {
          xml['cas'].user username
          append_user_info(username, xml)
        }
      }
    end
    render :xml => xml.to_xml
  end

  protected

  def not_authenticated
    redirect_to root_path, :alert => "Please login first."
  end

  def current_users_list
    current_users.map {|u| u.email}.join(", ")
  end

end
