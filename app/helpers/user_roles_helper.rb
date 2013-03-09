module UserRolesHelper
  def polymorphic_url(record_hash_array, options = {})
    # show and edit are about a user, not a specific UserRole
    if options[:action] && options[:action].in?([:show, :edit])
      case record_hash_array
      when UserRole then record_hash_array = record_hash_array.user
      when Array then record_hash_array =
        record_hash_array.map {|x| x.is_a? UserRole ? x.user : x}
      end
    end
    super
  end
end
