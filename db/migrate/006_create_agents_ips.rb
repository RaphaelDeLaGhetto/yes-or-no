class CreateAgentsIps < ActiveRecord::Migration
  def self.up
    create_table :agents_ips do |t|
      t.references :agent
      t.references :ip
      t.timestamps
    end
  end

  def self.down
    drop_table :agents_ips
  end
end
