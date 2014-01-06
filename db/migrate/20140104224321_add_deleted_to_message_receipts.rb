class AddDeletedToMessageReceipts < ActiveRecord::Migration
  def change
    add_column :message_receipts, :deleted, :boolean, null: false, default: false
  end
end
