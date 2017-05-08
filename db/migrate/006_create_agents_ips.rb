class CreateAgentsIps < ActiveRecord::Migration[5.1]
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
