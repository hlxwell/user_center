module Consumable
  extend ActiveSupport::Concern
  
  included do
    
  end
  
  module ClassMethods
    def cleanup
    end
  end
  
  module InstanceMethods
    def consume!
      update_attributes! :consumed => Time.now
    end
  end
end