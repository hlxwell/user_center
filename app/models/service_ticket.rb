class ServiceTicket < ActiveRecord::Base
  include Consumable
  include TicketLike

  SERVICES =  if Rails.env.production?
                [
                  "asics.client.sso.theplant-dev.com",
                  "myasics.client.sso.theplant-dev.com",
                  "sso.isafeplayer.com"
                ]
              else
                [
                  "en.lvh.me:4000",
                  "zh.lvh.me:4000"
                ]
              end

  belongs_to :granted_by_tgt,
             :class_name => 'TicketGrantingTicket',
             :foreign_key => :granted_by_tgt_id

  def self.correct_service? service
    SERVICES.include?(service)
  end

  def self.ticket_prefix
    "ST"
  end

  def valid_for_service? service_name
    self.service == service_name
  end
end