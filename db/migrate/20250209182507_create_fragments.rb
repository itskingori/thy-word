class CreateFragments < ActiveRecord::Migration[8.0]
  def change
    create_table :fragments do |t|
      t.references :bible, null: false, foreign_key: { on_delete: :restrict }
      t.references :book, null: false, foreign_key: { on_delete: :restrict }
      t.references :segment, null: false, foreign_key: { on_delete: :restrict }
      t.references :chapter, null: false, foreign_key: { on_delete: :restrict }
      t.references :heading, null: false, foreign_key: { on_delete: :restrict }
      t.references :verse, null: true, foreign_key: { on_delete: :restrict }
      t.boolean :show_verse, null: false
      t.string :kind, null: false
      t.text :content, null: false

      t.timestamps
    end
  end
end
