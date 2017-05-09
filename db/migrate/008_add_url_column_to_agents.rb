class AddUrlColumnToAgents < ActiveRecord::Migration[5.1]
  def self.up
    change_table :agents do |t|
      t.string :url
    end
  end

  def self.down
    change_table :agents do |t|
      t.remove :url
    end
  end
end
