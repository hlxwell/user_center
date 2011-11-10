class CreateLoginTickets < ActiveRecord::Migration
  def self.up
    create_table :login_tickets do |t|
      t.string :ticket
      t.string :client_hostname
      t.datetime :consumed

      t.timestamps
    end
  end

  def self.down
    drop_table :login_tickets
  end
end
