require 'spec_helper'

describe 'business_type/show', :type => :view do

  it 'has autocomplete turned off in the form' do
    assign(:registration, Registration.ctor(attrs={:id => 1}))
    render
    expect(rendered).to have_selector("form [autocomplete='off']")
  end

end
