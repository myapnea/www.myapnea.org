class CreateAnswers < ActiveRecord::Migration[4.2]
  def change
    create_table :answers do |t|
      t.references :question
      t.references :answer_session
      t.references :user
      t.timestamps
    end
  end
end
