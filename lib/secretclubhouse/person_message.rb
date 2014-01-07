module SecretClubhouse
  class PersonMessage < ActiveRecord::Base
    include BaseRecord
    self.table_name = 'person_message'
    target ::MessageReceipt, :delivered, :recipient_id

    def to_bmem_model
      Message.create! title: subject, from: message_from, body: body do |msg|
        msg.id = id
        msg.sender_id = creator_person_id
        msg.created_at = timestamp
      end
      receipt = super
      receipt.message_id = id
      receipt
    end

    def recipient_id
      person_id
    end

    def to_s
      "to #{person_id} #{subject}"
    end
  end
end
