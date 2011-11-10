class TicketGrantingTicket < ActiveRecord::Base
  include Consumable
  include TicketLike

  has_many :granted_service_tickets,
           :class_name => "ServiceTicket",
           :foreign_key => :granted_by_tgt_id

  def self.ticket_prefix
    "TGT"
  end  
end