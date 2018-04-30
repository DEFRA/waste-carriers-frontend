require 'spec_helper'

describe 'other_businesses/show', :type => :view do

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

  context "when having previously selected 'Yes'" do

    it "has the matching option selected" do
      assign(:registration, Registration.ctor(attrs={:otherBusinesses => 'yes'}))
      render
      expect(rendered).to have_selector('[id=registration_otherBusinesses_yes][checked=checked]')
    end
  end

  context "when having previously selected 'No'" do

    it "has the matching option selected" do
      assign(:registration, Registration.ctor(attrs={:otherBusinesses => 'no'}))
      render
      expect(rendered).to have_selector('[id=registration_otherBusinesses_no][checked=checked]')
    end
  end

end
