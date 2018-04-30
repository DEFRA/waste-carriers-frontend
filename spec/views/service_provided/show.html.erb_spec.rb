require 'spec_helper'

describe 'service_provided/show', :type => :view do

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
      assign(:registration, Registration.ctor(attrs={:isMainService => 'yes'}))
      render
      expect(rendered).to have_selector('[id=registration_isMainService_yes][checked=checked]')
    end
  end

  context "when having previously selected 'No'" do

    it "has the matching option selected" do
      assign(:registration, Registration.ctor(attrs={:isMainService => 'no'}))
      render
      expect(rendered).to have_selector('[id=registration_isMainService_no][checked=checked]')
    end
  end

end
