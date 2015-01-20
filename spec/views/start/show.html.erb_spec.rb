require 'spec_helper'

describe 'start/show', :type => :view do

  it 'has autocomplete turned off in the form' do
    assign(:registration, Registration.ctor(attrs={:id => 1}))
    render
    expect(rendered).to have_selector("form [autocomplete='off']")
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
      assign(:registration, Registration.ctor(attrs={:newOrRenew => 'renew'}))
      render
      expect(rendered).to have_selector('[id=registration_newOrRenew_renew][checked=checked]')
    end
  end

  context "when having previously selected 'No'" do

    it "has the matching option selected" do
      assign(:registration, Registration.ctor(attrs={:newOrRenew => 'new'}))
      render
      expect(rendered).to have_selector('[id=registration_newOrRenew_new][checked=checked]')
    end
  end

end
