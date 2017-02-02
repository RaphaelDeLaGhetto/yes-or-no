class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :url
      t.string :initials
      t.boolean :approved
      t.integer :yeses
      t.integer :nos
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
