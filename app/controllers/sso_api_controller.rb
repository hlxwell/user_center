###
# SSO API is used to provide LoginTicket and ServiceTicket to SSO client by JSONP.
# That other services can login through their website, without being redirected to UserCenter
#
class SsoApiController < ApplicationController
  respond_to :json

  def get_login_ticket
    respond_to do |format|
      format.json {
        if ServiceTicket.correct_service? get_service_from_referrer
          @lt = LoginTicket.create!(:client_hostname => request.remote_ip)
          render :json => { :lt => @lt.try(:ticket) }, :callback => params[:callback]
        else
          render :json => { :lt => nil }, :callback => params[:callback], :status => 422
        end
      }
    end
  end

  def get_service_ticket
    respond_to do |format|
      format.json {
        if !LoginTicket.validate_ticket(params[:lt])
          render :json => { :sts => nil, :message => "Wrong login ticket" }, :callback => params[:callback]
        elsif user = login(params[:email], params[:password], params[:remember])
          tgt = current_tgt || TicketGrantingTicket.create
          cookies.signed[:tgt] = tgt.to_s if cookies.signed[:tgt].blank?
          # issue service ticket
          sts = ServiceTicket::SERVICES.map do |service|
            ServiceTicket.create(
              :service => service,
              :username => current_user.email,
              :granted_by_tgt_id => tgt.id
            )
          end
          render :json => { :sts => sts.map {|st| CGI.escape "http://#{st.service}/privacy?ticket#{st.ticket}"}, :message => "success" }, :callback => params[:callback]
        else
          render :json => { :sts => nil, :message => "Wrong email or password" }, :callback => params[:callback]
        end
      }
    end
  end

  private

  def get_service_from_referrer
    get_url_host(request.referrer)
  end

end