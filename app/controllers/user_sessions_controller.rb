class UserSessionsController < ApplicationController
  skip_before_filter :require_login, :except => [:destroy]

  def new
    @user = User.new
    @lt = LoginTicket.create!(:client_hostname => request.remote_ip)
    store_service_url

    if logged_in? and has_service_info?
      redirect_to issue_service_ticket
      return
    end
  end

  # TODO: use cookies.signed[:name] to store cookie
  def create
    if !LoginTicket.validate_ticket(params[:lt])
      @lt = LoginTicket.create!(:client_hostname => request.remote_ip)
      flash.now[:alert] = "Invalid login ticket."
    elsif user = login(params[:email], params[:password], params[:remember])
      # create and store TGT
      tgt = TicketGrantingTicket.create
      cookies[:tgt] = tgt.to_s

      # issue service ticket
      @sts = ServiceTicket::SERVICES.map do |service|
        ServiceTicket.create(
          :service => service,
          :username => current_user.id,
          :granted_by_tgt_id => tgt.id
        )
      end

      if has_service_info?
        @back_url = issue_service_ticket
        render :layout => false
        return
      else
        flash[:notice] = 'Login successfull.'
        @back_url = session[:return_to_url] || root_url
        session[:return_to_url] = nil
        render :layout => false
        return
      end
    else
      @lt = LoginTicket.create!(:client_hostname => request.remote_ip)
      flash.now[:alert] = "Invalid login or password."
    end

    render :action => 'new'
  end

  def destroy
    # remove tgt
    if tgt = has_valid_tgt
      tgt.destroy
      cookies.delete(:tgt)
    end

    # logout session
    logout
    @back_url = if params[:destination]
                  params[:destination]
                else
                  flash[:notice] = "You have been logged out."
                  root_url
                end
    render :layout => false
  end

  # /serviceValidate checks the validity of a service ticket and returns an XML-fragment response.
  def serviceValidate
    service_name = get_url_host(params[:service])
    ticket = params[:ticket]

    # check the existance of service_url and ticket
    render_validation_error(:invalid_request) and return if service_name.blank? or ticket.blank?
    # can't find the ST from DB
    service_ticket = ServiceTicket.where(:ticket => ticket).unconsumed.first
    render_validation_error(:invalid_ticket, "ticket #{ticket} not recognized") and return unless service_ticket
    # validate if current ST is for current service.
    render_validation_error(:invalid_service) and return unless service_ticket.valid_for_service?(service_name)
    render_validation_success service_ticket.username
  end

  private

  def store_service_url
    service = get_url_host params[:service]

    if ServiceTicket.correct_service?(service)
      cookies[:service] = service
      cookies[:service_back_url] = CGI.unescape(params[:service])
    end
  end

end
