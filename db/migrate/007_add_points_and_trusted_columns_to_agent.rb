class AddPointsAndTrustedColumnsToAgent < ActiveRecord::Migration[5.1]
  def self.up
    change_table :agents do |t|
      t.integer :points, default: 0
      t.boolean :trusted, default: false
    end
  end

  def self.down
    change_table :agents do |t|
      t.remove :points
      t.remove :trusted
    end
  end
end
