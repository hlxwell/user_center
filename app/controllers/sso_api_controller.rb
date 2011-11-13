class SsoApiController < ApplicationController
  respond_to :json

  def get_login_ticket
    respond_to do |format|
      format.json {
        if ServiceTicket.correct_service? get_service_from_referrer
          @lt = LoginTicket.create!(:client_hostname => request.remote_ip)
        end
        render :json => { :lt => @lt.ticket }, :callback => params[:callback]
      }
    end
  end

  def get_service_ticket
    respond_to do |format|
      format.json {
        if !LoginTicket.validate_ticket(params[:lt])
          render :json => { :sts => nil, :message => "Wrong login ticket" }, :callback => params[:callback]
        elsif user = login(params[:email], params[:password], params[:remember])
          tgt = has_valid_tgt || TicketGrantingTicket.create
          cookies[:tgt] = tgt.to_s if cookies[:tgt].blank?

          # issue service ticket
          sts = ServiceTicket::SERVICES.map do |service|
            ServiceTicket.create(
              :service => service,
              :username => current_user.id,
              :granted_by_tgt_id => tgt.id
            )
          end

          render :json => { :sts => sts.map {|st| CGI.escape "http://#{st.service}:4000/privacy?ticket#{st.ticket}"}, :message => "success" }, :callback => params[:callback]
        end
      }
    end
  end

  private

  def get_service_from_referrer
    get_url_host(request.referrer)
  end

end