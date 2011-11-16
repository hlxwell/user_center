class ServiceTicket < ActiveRecord::Base
  include Consumable
  include TicketLike

  SERVICES = [
    "en.local.theplant-dev.com",
    "127.0.0.1",
    "en.lvh.me",
    "us.lvh.me",
    "nl.lvh.me",
    "uk.lvh.me",
    "fr.lvh.me",
    "de.lvh.me",
    "a.lvh.me",
    "b.lvh.me",
    "c.lvh.me",
    "d.lvh.me",
    "e.lvh.me",
    "f.lvh.me",
    "g.lvh.me",
    "h.lvh.me",
    "i.lvh.me",
    "j.lvh.me",
    "k.lvh.me",
    "l.lvh.me",
    "m.lvh.me",
    "n.lvh.me",
    "o.lvh.me",
    "p.lvh.me",
    "q.lvh.me",
    "r.lvh.me",
    "s.lvh.me",
    "t.lvh.me",
    "u.lvh.me",
    "v.lvh.me",
    "w.lvh.me",
    "x.lvh.me",
    "y.lvh.me",
    "z.lvh.me"
  ]

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