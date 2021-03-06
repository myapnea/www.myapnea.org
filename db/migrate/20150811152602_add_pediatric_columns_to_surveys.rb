class AddPediatricColumnsToSurveys < ActiveRecord::Migration[4.2]
  def change
    add_column :surveys, :pediatric, :boolean, null: false, default: false
    add_column :surveys, :child_min_age, :integer
    add_column :surveys, :child_max_age, :integer
  end
end
