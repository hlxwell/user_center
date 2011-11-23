module TicketLike
  extend ActiveSupport::Concern

  included do
    # TODO check ticket_prefix method

    validates_uniqueness_of :ticket
    before_create :set_ticket
    scope :unconsumed, where(:consumed => nil)
    scope :consumed, where(:consumed => true)
  end

  module ClassMethods
    def validate_ticket ticket
      if lt = self.unconsumed.where(:ticket => ticket).first
        lt.consume!
        true
      else
        false
      end
    end

    # max_lifetime
    # max_unconsumed_lifetime
    #
    def cleanup(max_lifetime, max_unconsumed_lifetime)
      transaction do
        conditions = ["created_at < ? OR (consumed IS NULL AND created_at < ?)",
                        Time.now - max_lifetime,
                        Time.now - max_unconsumed_lifetime]

        expired_tickets_count = count(:conditions => conditions)
        # logger.info("Destroying #{expired_tickets_count} expired #{self.name.demodulize} #{'s' if expired_tickets_count > 1}.") if expired_tickets_count > 0
        destroy_all(conditions)
      end
    end
  end

  module InstanceMethods
    def unused?
      if t = self.class.unconsumed.where(:ticket => self.ticket).first
        t.consume!
        true
      else
        false
      end
    end

    def set_ticket
      self.ticket = "#{self.class.ticket_prefix}-#{rand(100000000000000000)}".to_s
    end

    def to_s
      self.ticket
    end
  end
end