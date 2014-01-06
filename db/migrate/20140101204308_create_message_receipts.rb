class CreateMessageReceipts < ActiveRecord::Migration
  def change
    create_table :message_receipts do |t|
      t.references :message, null: false
      t.references :recipient, null: false
      t.boolean :delivered, null: false, default: false

      t.timestamps
    end
    add_index :message_receipts, :message_id
    add_index :message_receipts, :recipient_id
  end
end
