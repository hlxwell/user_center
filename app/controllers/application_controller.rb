class ApplicationController < ActionController::Base
  protect_from_forgery

  # before_filter :require_login, :except => [:not_authenticated]
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
          # append_user_info(username, xml)
        }
      }
    end
    render :xml => xml.to_xml
  end

  def get_url_host url
    URI::parse(CGI.unescape(url.to_s)).host
  end

  protected

  def has_valid_tgt
    TicketGrantingTicket.where(:ticket => cookies[:tgt]).unconsumed.first
  end

  # issue a Service Ticket and redirect back
  def issue_service_ticket
    if tgt = has_valid_tgt and cookies[:service] and cookies[:service_back_url]
      # TODO need to verify params[:service] included in "available services"
      st = ServiceTicket.create(
        :service => cookies[:service],
        :username => current_user.id,
        :granted_by_tgt_id => tgt.id
      )
      back_url = cookies[:service_back_url]
      cookies.delete :service
      cookies.delete :service_back_url

      redirect_to back_url
      return
    end
  end

  def not_authenticated
    redirect_to root_path, :alert => "Please login first."
  end

  def current_users_list
    current_users.map {|u| u.email}.join(", ")
  end

end
