class RenameParticipantsToInvolvements < ActiveRecord::Migration
  def up
    # handle SQLite temp index names that are too long
    rename_index :arts_participants, "index_arts_participants_on_participant_id_and_art_id", "index_arts_participants_pair"
    rename_index :participants_slots, "index_participants_slots_on_participant_id_and_slot_id", "index_participants_slots_pair"

    rename_column :participants, :participation_status, :involvement_status
    rename_table :participants, :involvements
    rename_column :arts_participants, :participant_id, :involvement_id
    rename_table :arts_participants, :arts_involvements
    rename_column :participants_slots, :participant_id, :involvement_id
    rename_table :participants_slots, :involvements_slots
    rename_column :work_logs, :participant_id, :involvement_id
  end

  def down
    rename_column :work_logs, :involvement_id, :participant_id
    rename_table :involvements_slots, :participants_slots
    rename_column :participants_slots, :involvement_id, :participant_id
    rename_table :arts_involvements, :arts_participants
    rename_column :arts_participants, :involvement_id, :participant_id
    rename_table :involvements, :participants
    rename_column :participants, :involvement_status, :participation_status
  end
end
