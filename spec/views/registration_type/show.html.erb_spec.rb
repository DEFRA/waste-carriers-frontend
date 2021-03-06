require 'spec_helper'

describe 'registration_type/show', :type => :view do

  it 'has autocomplete turned off in the form' do
    assign(:registration, Registration.ctor(attrs={:id => 1}))
    render
    expect(rendered).to have_selector("[autocomplete=off]")
  end

  context "when first visting the page" do

    it "has no option pre-selected" do
      assign(:registration, Registration.ctor(attrs={:id => 1}))
      render
      expect(rendered).to_not have_selector('[checked=checked]')
    end

  end

  context "when having previously selected 'carrier_dealer'" do

    it "has the matching option selected" do
      assign(:registration, Registration.ctor(attrs={:registrationType => 'carrier_dealer'}))
      render
      expect(rendered).to have_selector('[id=registration_registrationType_carrier_dealer][checked=checked]')
    end

  end

  context "when having previously selected 'broker_dealer'" do

    it "has the matching option selected" do
      assign(:registration, Registration.ctor(attrs={:registrationType => 'broker_dealer'}))
      render
      expect(rendered).to have_selector('[id=registration_registrationType_broker_dealer][checked=checked]')
    end

  end

  context "when having previously selected 'carrier_broker_dealer'" do

    it "has the matching option selected" do
      assign(:registration, Registration.ctor(attrs={:registrationType => 'carrier_broker_dealer'}))
      render
      expect(rendered).to have_selector('[id=registration_registrationType_carrier_broker_dealer][checked=checked]')
    end

  end

end
