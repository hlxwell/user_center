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
  end

  module InstanceMethods
    def set_ticket
      self.ticket = "#{self.class.ticket_prefix}-#{rand(100000000000000000)}".to_s
    end

    def to_s
      self.ticket
    end
  end
end