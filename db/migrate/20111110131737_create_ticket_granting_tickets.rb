class CreateTicketGrantingTickets < ActiveRecord::Migration
  def self.up
    create_table :ticket_granting_tickets do |t|
      t.string :ticket
      t.string :client_hostname
      t.string :username
      t.text :extra_attributes
      t.datetime :consumed

      t.timestamps
    end
  end

  def self.down
    drop_table :ticket_granting_tickets
  end
end
