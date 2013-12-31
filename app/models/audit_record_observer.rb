class AuditRecordObserver < ActiveModel::Observer
  observe Audited.audit_class

  def before_create(audit)
    if audit.comment.blank?
      Thread.current[:default_audit_comment].presence.try do |comment|
        audit.comment = comment
      end
    end
  end

  def add_observer!(klass)
    super
    define_callback(klass)
  end

  # Don't assume Audit is an ActiveRecord. Following Audited::Sweeper example.
  def define_callback(klass)
    observer = self
    callback_meth = :"_notify_audit_record_observer_for_before_create"
    klass.send(:define_method, callback_meth) do
      observer.update(:before_create, self)
    end
    klass.send(:before_create, callback_meth)
  end
end
