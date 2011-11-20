class User < ActiveRecord::Base
  attr_accessible :email, :password, :password_confirmation, :providers_attributes

  has_many :providers, :class_name => "UserProvider", :dependent => :destroy
  accepts_nested_attributes_for :providers

  validates_uniqueness_of :email, :case_sensitive => false, :allow_blank => false
  validates_length_of :password, :minimum => 3, :message => "password must be at least 3 characters long", :if => :password
  validates_confirmation_of :password, :message => "should match confirmation", :if => :password

  authenticates_with_sorcery!
end
