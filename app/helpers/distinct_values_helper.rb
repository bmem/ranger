module DistinctValuesHelper
  # distinct_values(Person, :status)
  # distinct_values(Person.some_scope, 'name') {|p| p.name[1].upcase}
  def distinct_values(relation, field, &block)
    q = relation.select(field).where("#{field} IS NOT NULL").reorder(field).uniq
    if block_given?
      q.map(&block).uniq
    else
      q.map {|val| val.send field}
    end
  end
end
