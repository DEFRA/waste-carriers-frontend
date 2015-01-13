#spec/views/registrations/newOrRenew.html.erb_spec.rb

require 'spec_helper'

describe 'registrations/newOrRenew.html.erb' do

  it 'has autocomplete turned off in the form' do
    assign(:registration, Registration.ctor())
    render
    rendered.should have_selector("form [autocomplete='off']")
  end
end