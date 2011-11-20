##
# Validator is used to validate ServiceTicket
#
class ValidatorsController < ApplicationController
  before_filter :set_variables

  def serviceValidate
    # check the existance of service_url and ticket
    render_validation_error(:invalid_request) and return if @service.blank? or @ticket.blank?
    # find the ST from DB
    render_validation_error(:invalid_ticket, "ticket #{@ticket} not recognized") and return unless @st
    # validate if current ST is for current service.
    render_validation_error(:invalid_service) and return unless @st.valid_for_service?(@service)
    # if ServiceTicket is unused return success
    render_validation_success @st.username and return if @st.unused?

    render_validation_error(:invalid_request)
  end

  private

  def set_variables
    @service = get_url_host(params[:service])
    @ticket = params[:ticket]
    @st = ServiceTicket.where(:ticket => @ticket).first
  end

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
end
