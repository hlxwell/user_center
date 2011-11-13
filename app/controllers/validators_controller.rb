class ValidatorsController < ApplicationController
  before_filter :set_variables

  # def proxyValidate
  # end

  def serviceValidate
    # check the existance of service_url and ticket
    render_validation_error(:invalid_request) and return if @service.blank? or @ticket.blank?

    # find the ST from DB
    render_validation_error(:invalid_ticket, "ticket #{@ticket} not recognized") and return unless @st

    # validate if current ST is for current service.
    render_validation_error(:invalid_service) and return unless @st.valid_for_service?(@service)

    render_validation_success @st.username and return if @st.unused?

    render_validation_error(:invalid_request)
  end

  private

  def set_variables
    @service = get_url_host(params[:service])
    @ticket = params[:ticket]
    @st = ServiceTicket.where(:ticket => @ticket).first
  end
end
