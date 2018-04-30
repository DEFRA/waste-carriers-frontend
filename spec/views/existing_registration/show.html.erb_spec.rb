require 'spec_helper'

describe 'existing_registration/show', :type => :view do

  it 'has autocomplete turned off in the form' do
    assign(:registration, Registration.ctor(attrs={:id => 1}))
    render
    expect(rendered).to have_selector("[autocomplete=off]")
  end

  context "when first visting the page" do

    it "no value is entered" do
      assign(:registration, Registration.ctor(attrs={:id => 1}))
      render
      expect(rendered).to have_selector("input#registration_originalRegistrationNumber", :text => "")
    end

  end

  context "when having previously entered 'CB/AE8888XX/A001'" do

    it "displays the value in the text field" do
      assign(:registration, Registration.ctor(attrs={:originalRegistrationNumber => 'CB/AE8888XX/A001'}))
      render
      expect(rendered).to have_selector("input[id=registration_originalRegistrationNumber][value='CB/AE8888XX/A001']")
    end
  end

end
