class CreateBibles < ActiveRecord::Migration[8.0]
  def change
    create_table :bibles do |t|
      t.string :name, null: false
      t.string :code, null: false, limit: 3
      t.text :statement, null: false
      t.string :rights_holder_name, null: false
      t.string :rights_holder_url, null: false

      t.timestamps
    end

    add_index :bibles, :code, unique: true
  end
end
