class CreateBroadcasts < ActiveRecord::Migration
  def change
    create_table :broadcasts do |t|
      t.string :title
      t.string :slug
      t.string :short_description
      t.string :keywords
      t.text :description
      t.integer :user_id
      t.date :publish_date
      t.boolean :pinned, null: false, default: false
      t.boolean :archived, null: false, default: false
      t.boolean :published, null: false, default: false
      t.boolean :deleted, null: false, default: false

      t.timestamps null: false
    end

    add_index :broadcasts, :slug, unique: true
    add_index :broadcasts, :user_id
    add_index :broadcasts, :publish_date
    add_index :broadcasts, :pinned
    add_index :broadcasts, :archived
    add_index :broadcasts, :published
    add_index :broadcasts, :deleted
  end
end