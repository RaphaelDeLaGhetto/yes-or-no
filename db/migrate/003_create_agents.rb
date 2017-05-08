class CreateAgents < ActiveRecord::Migration[5.1]
  def self.up
    create_table :agents do |t|
      t.string :name
      t.string :email, unique: true, null: false
      t.string :password_hash
      t.string :confirmation_hash
      t.timestamps
    end
  end

  def self.down
    drop_table :agents
  end
end
