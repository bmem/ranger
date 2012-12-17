# Ensure single table inheritance child models are all loaded
# TODO why does this get a LoadError?
if false && Rails.env.development?
  %w(burning_man, general_event, training).each do |c|
    require_dependency File.join('app', 'models', "#{c}.rb")
  end
end
