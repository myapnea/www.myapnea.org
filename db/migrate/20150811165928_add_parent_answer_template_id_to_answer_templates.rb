class AddParentAnswerTemplateIdToAnswerTemplates < ActiveRecord::Migration[4.2]
  def change
    add_column :answer_templates, :parent_answer_template_id, :integer
    add_index :answer_templates, :parent_answer_template_id
  end
end
