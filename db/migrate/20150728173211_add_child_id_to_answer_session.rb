class AddChildIdToAnswerSession < ActiveRecord::Migration
  def change
    add_column :answer_sessions, :child_id, :integer
    add_index :answer_sessions, :child_id
  end
end
