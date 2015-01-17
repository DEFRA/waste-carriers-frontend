require 'spec_helper'

describe 'business_type/show', :type => :view do

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

  context "when having previously selected 'Sole Trader'" do

    it "has the matching option selected" do
      assign(:registration, Registration.ctor(attrs={:businessType => 'soleTrader'}))
      render
      expect(rendered).to have_selector('[id=registration_businessType_soletrader][checked=checked]')
    end
  end

  context "when having previously selected 'Partnership'" do

    it "has the matching option selected" do
      assign(:registration, Registration.ctor(attrs={:businessType => 'partnership'}))
      render
      expect(rendered).to have_selector('[id=registration_businessType_partnership][checked=checked]')
    end
  end

  context "when having previously selected 'Limited company'" do

    it "has the matching option selected" do
      assign(:registration, Registration.ctor(attrs={:businessType => 'limitedCompany'}))
      render
      expect(rendered).to have_selector('[id=registration_businessType_limitedcompany][checked=checked]')
    end
  end

  context "when having previously selected 'Public body'" do

    it "has the matching option selected" do
      assign(:registration, Registration.ctor(attrs={:businessType => 'publicBody'}))
      render
      expect(rendered).to have_selector('[id=registration_businessType_publicbody][checked=checked]')
    end
  end

  context "when having previously selected 'Charity or voluntary organisation'" do

    it "has the matching option selected" do
      assign(:registration, Registration.ctor(attrs={:businessType => 'charity'}))
      render
      expect(rendered).to have_selector('[id=registration_businessType_charity][checked=checked]')
    end
  end

  context "when having previously selected 'Waste collection, disposal or regulation authority'" do

    it "has the matching option selected" do
      assign(:registration, Registration.ctor(attrs={:businessType => 'authority'}))
      render
      expect(rendered).to have_selector('[id=registration_businessType_authority][checked=checked]')
    end
  end

  context "when having previously selected 'Other'" do

    it "has the matching option selected" do
      assign(:registration, Registration.ctor(attrs={:businessType => 'other'}))
      render
      expect(rendered).to have_selector('[id=registration_businessType_other][checked=checked]')
    end
  end

end
