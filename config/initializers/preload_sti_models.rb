# Ensure single table inheritance child models are all loaded
if Rails.env.development?
  events = %w(burning_man general_event training_season)
  assets = %w(radio vehicle key)
  auths = %w(radio event_radio vehicle rental_vehicle).map {|m| "#{m}_authorization" }
  (events + assets + auths).each do |c|
    require_dependency File.join('app', 'models', "#{c}.rb")
  end
end
