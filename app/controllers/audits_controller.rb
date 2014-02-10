class AuditsController < ApplicationController
  include DistinctValuesHelper
  helper_method :distinct_auditable_types
  after_filter :verify_authorized, except: :index
  after_filter :verify_policy_scoped, only: :index

  def index
    @audits = policy_scope(Audited.audit_class)
    if [:type, :record_id].map {|x| params[x]}.all?(&:present?)
      @audits = @audits.where(
        '(auditable_type = :type AND auditable_id = :id) OR (associated_type = :type AND associated_id = :id)',
        type: params[:type], id: params[:record_id])
    elsif params[:type].present?
      @audits = @audits.where('? IN (auditable_type, associated_type)', params[:type])
    end
    @audits = filter_by @audits, :user_id
    @audits = filter_by @audits, :start_date,
      'created_at >= ?', params[:start_date]
    if params[:end_date].present?
      @audits = filter_by @audits, :end_date,
        'created_at < ?', params[:end_date].to_date + 1.day
    end
    @audits = order_by_params @audits
    @audits = @audits.page(params[:page])
  end

  def show
    @audit = Audited.audit_class.find(params[:id])
    authorize @audit
    respond_to do |format|
      format.html # show.html.haml
      format.json { render json: @audit }
    end
  end

  def subject_record
    @audit
  end

  def default_sort_column
    'created_at'
  end

  def default_sort_column_direction
    'desc'
  end

  def distinct_auditable_types
    cache :distinct_auditable_types do
      [:auditable_type, :associated_type].map do |field|
        distinct_values(Audited.audit_class, field)
      end.flatten.uniq.sort
    end
  end

  private
  def filter_by(collection, field, *conditions)
    if params[field].present?
      if conditions.present?
        collection.where *conditions
      else
        collection.where field => params[field]
      end
    else
      collection
    end
  end
end
