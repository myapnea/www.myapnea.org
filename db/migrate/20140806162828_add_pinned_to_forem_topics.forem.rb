class AddPinnedToForemTopics < ActiveRecord::Migration[4.2]
  def change
    add_column :forem_topics, :pinned, :boolean, default: false, null: false
  end
end
