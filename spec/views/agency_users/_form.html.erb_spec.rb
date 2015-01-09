require 'rspec'
require 'capybara/rspec'

describe 'autocomplete turned off in form' do

  it 'tests that the form has autocomplete turned off' do
    render
    rendered.should have_selector(  'form',
                                    :html => 'autocomplete="off"')
  end
end