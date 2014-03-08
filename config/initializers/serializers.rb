ActiveSupport.on_load(:active_model_serializers) do
  # Don't disable root, allowing "embed :ids, innclude: true"
  # TODO don't disable this; make singularizing resources easy in JS
  #ActiveModel::Serializer.root = false

  # Don't disable root property for ArraySerializer to support returning meta
  # properties for pagination
  #ActiveModel::ArraySerializer.root = false
end
