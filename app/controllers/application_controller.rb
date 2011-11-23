class ApplicationController < ActionController::Base
  protect_from_forgery

  def get_url_host url
    url = URI::parse(CGI.unescape(url.to_s))
    url.port.to_s == "80" ? url.host : "#{url.host}:#{url.port}"
  end
  helper_method :get_url_host

  def has_service_info?
    cookies[:service].present? and cookies[:service_back_url].present?
  end

  def current_tgt
    # unconsumed is meaningless, since it will be deleted after logout
    TicketGrantingTicket.where(:ticket => cookies.signed[:tgt]).first
  end

  def not_authenticated
    redirect_to root_path, :alert => "Please login first."
  end

  # Issue a Service Ticket and return a url with this st
  def back_url_with_service_ticket
    if tgt = current_tgt and has_service_info?
      st = ServiceTicket.create(
        :service => cookies[:service],
        :username => current_user.email,
        :granted_by_tgt_id => tgt.id
      )

      service_back_url = cookies[:service_back_url] + "?ticket=#{st.ticket}"

      # remove service info
      cookies.delete :service
      cookies.delete :service_back_url

      service_back_url
    end
  end
end
