#spec/views/registrations/approve.html.erb_spec.rb

require 'spec_helper'

describe 'registrations/approve.html.erb' do

  it 'has autocomplete turned off in the form' do
    assign(:registration, Registration.ctor(attrs={:id => 1}))
    render
    rendered.should have_selector("form [autocomplete='off']")
  end
end