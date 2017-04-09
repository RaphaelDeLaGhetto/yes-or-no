class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.references :post
      t.references :agent
      t.references :ip
      t.boolean :yes, default: false
      t.timestamps
    end
  end

  def self.down
    drop_table :votes
  end
end
