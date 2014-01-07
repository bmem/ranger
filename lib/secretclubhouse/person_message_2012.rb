module SecretClubhouse
  # In the absence of "delete", old person_message got saved in a backup table
  class PersonMessage2012 < PersonMessage
    include BaseRecord
    self.table_name = 'person_message_2012'
    target ::MessageReceipt, :delivered, :recipient_id
  end
end
