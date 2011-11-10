class CreateServiceTickets < ActiveRecord::Migration
  def self.up
    create_table :service_tickets do |t|
      t.string :ticket
      t.string :service
      t.string :client_hostname
      t.string :username
      t.integer :granted_by_tgt_id
      t.datetime :consumed

      t.timestamps
    end
  end

  def self.down
    drop_table :service_tickets
  end
end
