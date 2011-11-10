class UserSessionsController < ApplicationController
  skip_before_filter :require_login, :except => [:destroy]

  def new
    @user = User.new
    @lt = LoginTicket.create
    @service = params[:service] if ServiceTicket.correct_service?(params[:service])
  end

  def create
    if !LoginTicket.validate_ticket(params[:lt])
      flash.now[:alert] = "Invalid login ticket."
    elsif user = login(params[:email], params[:password], params[:remember])
      tgt = TicketGrantingTicket.create
      cookies[:tgt] = tgt.to_s

      if params[:service]
        issue_service_ticket
        return
      else
        redirect_back_or_to(:users, :notice => 'Login successfull.')
        return
      end
    else
      @lt = LoginTicket.create
      flash.now[:alert] = "Invalid login or password."
    end

    respond_to do |format|
      format.json {
        render :json => {:name => "michael he"}.to_json, :callback => params[:callback]
      }
      format.html { render :action => 'new' }
    end
  end

  # if has a validated TGT in cookie:
  # 1. remove it from cookie
  # 2. remove it from redis
  # 3. logout warden.
  #
  def destroy
    if tgt = has_valid_tgt
      tgt.destroy
      cookies.delete(:tgt)
    end
    logout
    redirect_to root_url, :notice => "You have been logged out."
  end

  def tgtValidate
    ticket = params[:tgt]
    tgt = TicketGrantingTicket.where(:ticket => ticket).first
    render :json => tgt.present? ? {:result => true} : {:result => false}
  end

  # /serviceValidate checks the validity of a service ticket and returns an XML-fragment response.
  def serviceValidate
    service_name = params[:service]
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

  def has_valid_tgt
    TicketGrantingTicket.where(:ticket => cookies[:tgt]).unconsumed.first
  end

  def issue_service_ticket
    if tgt = has_valid_tgt and params[:service]
      # TODO need to verify params[:service] included in "available services"
      st = ServiceTicket.create(
        :service => params[:service],
        :username => current_user.id,
        :granted_by_tgt_id => tgt.id
      )
      redirect_to st.service_callback_url
      return
    end
  end

end
