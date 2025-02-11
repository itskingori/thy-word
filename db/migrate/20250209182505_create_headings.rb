class CreateHeadings < ActiveRecord::Migration[8.0]
  def change
    create_table :headings do |t|
      t.references :bible, null: false, foreign_key: { on_delete: :restrict }
      t.references :book, null: false, foreign_key: { on_delete: :restrict }
      t.references :chapter, null: false, foreign_key: { on_delete: :restrict }
      t.integer :level, null: false
      t.string :title, null: false

      t.timestamps
    end
  end
end
