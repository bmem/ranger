ActiveSupport.on_load(:active_model_serializers) do
  # Disable root property for all serializers (except ArraySerializer)
  # TODO don't disable this; make singularizing resources easy in JS
  ActiveModel::Serializer.root = false

  # Don't disable root property for ArraySerializer to support returning meta
  # properties for pagination
  #ActiveModel::ArraySerializer.root = false
end
