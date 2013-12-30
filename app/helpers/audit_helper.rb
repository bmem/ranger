module AuditHelper
  def associated_audits_for(record, *assoc_types)
    audits = record.associated_audits
    if assoc_types.flatten.any?
      audits = audits.where(auditable_type: assoc_types.map do |t|
        case t
        when Class then t.to_s
        when Symbol then t.to_s.camelize
        else t
        end
      end)
    end
    if sort_column.in? Audited::Adapters::ActiveRecord::Audit.attribute_names
      audits = audits.reorder("#{sort_column} #{sort_direction}")
    else
      audits = audits.reorder('created_at DESC')
    end
  end
end
