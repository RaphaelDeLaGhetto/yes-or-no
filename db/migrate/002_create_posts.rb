class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :url
      t.string :tag
      t.boolean :approved, default: false
      t.integer :yeses, default: 0
      t.integer :nos, default: 0
      t.references :agent
      t.references :ip
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
