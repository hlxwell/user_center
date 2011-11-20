class SessionsController < ApplicationController
  skip_before_filter :require_login, :except => [:destroy]
  before_filter :store_service_url, :only => [:new]
  before_filter :validate_login_ticket, :only => [:create]

  def new
    @user = User.new
    @lt = LoginTicket.create!(:client_hostname => request.remote_ip)
    redirect_to back_url_with_service_ticket and return if logged_in? and has_service_info?
  end

  def create
    # Login success
    if user = login(params[:email], params[:password], params[:remember])
      # create and store TGT
      tgt = TicketGrantingTicket.create!
      cookies.signed[:tgt] = tgt.to_s

      # issue service tickets for each service.
      @sts = ServiceTicket::SERVICES.map do |service|
        ServiceTicket.create(
          :service => service,
          :username => current_user.id,
          :granted_by_tgt_id => tgt.id
        )
      end

      if has_service_info?
        @back_url = back_url_with_service_ticket
      else
        flash[:notice] = 'Login successfull.'
        @back_url = root_url
      end
      render :layout => 'redirecting'

    # Login failed.
    else
      flash.keep[:alert] = "Invalid login or password."
      redirect_to new_session_path
    end
  end

  def destroy
    remove_tgt
    logout
    @back_url = if params[:destination]
                  params[:destination]
                else
                  flash[:notice] = "You have been logged out."
                  root_url
                end
    render :layout => 'redirecting'
  end

  private

  # FIXME: store service in session will has some errors.
  def store_service_url
    service = get_url_host params[:service]
    if ServiceTicket.correct_service?(service)
      cookies[:service] = service
      cookies[:service_back_url] = CGI.unescape(params[:service])
    end
  end

  def validate_login_ticket
    if !LoginTicket.validate_ticket(params[:lt])
      flash.keep[:alert] = "Invalid login ticket."
      redirect_to new_session_path
    end
  end

  def remove_tgt
    if tgt = current_tgt
      tgt.destroy
      cookies.delete(:tgt)
    end
  end
end
