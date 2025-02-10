class CreateChapters < ActiveRecord::Migration[8.0]
  def change
    create_table :chapters do |t|
      t.references :bible, null: false, foreign_key: { on_delete: :restrict }
      t.references :book, null: false, foreign_key: { on_delete: :restrict }
      t.integer :number, null: false

      t.timestamps
    end

    add_index :chapters, [ :bible_id, :book_id, :number ], unique: true
  end
end
