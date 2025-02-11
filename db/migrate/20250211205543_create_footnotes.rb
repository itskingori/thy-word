class CreateFootnotes < ActiveRecord::Migration[8.0]
  def change
    create_table :footnotes do |t|
      t.references :bible, null: false, foreign_key: { on_delete: :restrict }
      t.references :book, null: false, foreign_key: { on_delete: :restrict }
      t.references :chapter, null: false, foreign_key: { on_delete: :restrict }
      t.references :verse, null: false, foreign_key: { on_delete: :restrict }
      t.text :content, null: false

      t.timestamps
    end
  end
end
