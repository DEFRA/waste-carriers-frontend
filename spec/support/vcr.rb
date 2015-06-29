VCR.configure do |c|
  c.cassette_library_dir = Rails.root.join('spec', 'vcr')
  c.hook_into :webmock
  c.ignore_request do |req|
    URI(req.uri).port == URI(Rails.configuration.waste_exemplar_elasticsearch_url).port
  end
end

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
  c.around(:each, :vcr) do |example|
    name = example.metadata[:full_description].split(/\s+/, 2).join("/").underscore.gsub(/[^\w\/]+/, "_")
    VCR.use_cassette(name, re_record_interval: 7.days) { example.call }
  end
end
