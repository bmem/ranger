class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :type
      t.string :title
      t.string :from
      t.string :to
      t.datetime :expires
      t.references :sender, null: false
      t.text :body

      t.timestamps
    end
    add_index :messages, :sender_id
  end
end
