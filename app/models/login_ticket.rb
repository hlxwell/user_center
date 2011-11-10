class LoginTicket < ActiveRecord::Base
  include Consumable
  include TicketLike

  def self.ticket_prefix
    "LT"
  end
end