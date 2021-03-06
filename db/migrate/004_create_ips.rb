class CreateIps < ActiveRecord::Migration[5.1]
  def self.up
    create_table :ips do |t|
      t.string :address
      t.boolean :expired, default: false
      t.timestamps
    end
  end

  def self.down
    drop_table :ips
  end
end
