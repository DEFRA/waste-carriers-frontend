require 'spec_helper'

describe 'postal_address/show', type: :view do

  it 'has autocomplete turned off in the form' do
    assign(:registration, Registration.ctor(id: 1))
    assign(:address, Address.create)
    render
    expect(rendered).to have_selector("form [autocomplete='off']")
  end

end
