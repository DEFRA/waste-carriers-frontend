VCR.configure do |c|
  c.cassette_library_dir = Rails.root.join('spec', 'vcr')
  c.hook_into :webmock

  # Strip out authorization info
  c.filter_sensitive_data("Basic <COMPANIES_HOUSE_API_KEY>") do |interaction|
    if interaction.request.headers["Authorization"].present?
      interaction.request.headers["Authorization"].first
    end
  end
end

RSpec.configure do |c|
  c.around(:each, :vcr) do |example|
    name = example.metadata[:full_description].split(/\s+/, 2).join("/").underscore.gsub(/[^\w\/]+/, "_")
    VCR.use_cassette(name) { example.call }
  end
end
