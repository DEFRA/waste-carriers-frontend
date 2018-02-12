require 'spec_helper'

describe 'registrations/declaration', type: :view do
  let!(:ir_renewal) { create(:irrenewal, :company) }

  context "when registration is new" do

    subject(:registration) { create(:registration) }

    it 'displays the correct charge wording' do
      assign(:registration, subject)
      assign(:registration_order, subject.registration_order)

      render

      expect(rendered).to have_text("Based on the information you provided, you are an upper tier waste carrier.")
      expect(rendered).to have_text("The charge for this is £154, which will register you for 3 years")
      expect(rendered).to_not have_text("renewal")
      expect(rendered).to_not have_text("Editing your registration")

    end
  end

  context "when registration is a renewal" do
    subject(:ir_renewal_registration) { create(:registration, :ir_renewal) }

    it 'displays the correct charge wording' do
      RegistrationOrder.any_instance.stub(:ir_renewal).and_return(subject)
      assign(:registration, subject)
      assign(:registration_order, subject.registration_order)

      render

      expect(rendered).to have_text("The renewal charge is £105, which will register you for 3 years.")
      expect(rendered).to_not have_text("The charge is £105, which will register you for 3 years.")

      expect(rendered).to_not have_text("Editing your registration")
    end
  end

  context "when registration is being edited" do

    subject(:editing_registration) { create(:registration, :editing) }

    it 'displays the correct introductory wording' do
      flash[:start_editing] = true # normally set on the previous page (user registration list)
      RegistrationOrder.any_instance.stub(:original_registration).and_return(subject)
      assign(:registration, subject)
      assign(:registration_order, subject.registration_order)

      render

      expect(rendered).to have_text("Editing your registration")
      expect(rendered).to have_text("You can make changes to your registration from this summary. Some charges may apply.")
    end

    it 'displays the correct £40 charge' do
      RegistrationOrder.any_instance.stub(:original_registration).and_return(create(:registration, :editing))
      subject.registrationType = 'carrier_dealer'
      subject.save
      assign(:registration, subject)
      assign(:registration_order, subject.registration_order)

      render

      expect(rendered).to have_text("Editing your registration")
      expect(rendered).to have_text("Please be aware that the changes you have made will require a payment of £40")

      expect(rendered).to_not have_text("Some charges may apply.")
      expect(rendered).to_not have_text("£145")
      expect(rendered).to_not have_text("£154")
    end

    it 'displays the correct £145 charge' do
      RegistrationOrder.any_instance.stub(:ir_renewal).and_return(create(:registration, :ir_renewal))
      editing_renewal_registration = create(:registration, :ir_renewal, :editing, registrationType: 'carrier_dealer')
      assign(:registration, editing_renewal_registration)
      assign(:registration_order, editing_renewal_registration.registration_order)

      render

      expect(rendered).to have_text("You are about to renew your registration.")
      expect(rendered).to have_text("The renewal charge is £145, which will register you for 3 years.")

      expect(rendered).to_not have_text("Some charges may apply.")
      expect(rendered).to_not have_text("£40")
      expect(rendered).to_not have_text("£154")
    end

    it 'displays the correct £154 charge when a change caused new' do
      RegistrationOrder.any_instance.stub(:ir_renewal).and_return(create(:registration, :ir_renewal))
      editing_renewal_registration = create(:registration, :ir_renewal, :editing, businessType: 'soleTrader') # changing to soleTrader triggers change caused new
      assign(:registration, editing_renewal_registration)
      assign(:registration_order, editing_renewal_registration.registration_order)
      render

      expect(rendered).to have_text("You are about to renew your registration.")
      expect(rendered).to have_text("The renewal charge is £154, which will register you for 3 years.")

      expect(rendered).to_not have_text("Some charges may apply.")
      expect(rendered).to_not have_text("£40")
      expect(rendered).to_not have_text("£145")
    end

    it 'displays the correct £154 charge when an expired renewal is used' do
      expired_ir_renewal_registration = create(:registration, :ir_renewal, originalDateExpiry: Date.today - 3.months)
      RegistrationOrder.any_instance.stub(:ir_renewal).and_return(expired_ir_renewal_registration)

      renewal_registration = create(:registration, :ir_renewal, originalDateExpiry: Date.today - 3.months)
      assign(:registration, renewal_registration)
      assign(:registration_order, renewal_registration.registration_order)
      render

      expect(rendered).to have_text("Your previous registration has expired.")
      expect(rendered).to have_text("The charge for this is £154", count: 1)
      expect(rendered).to_not have_text("£105")

      expect(rendered).to_not have_text("Editing your registration")
    end

  end

end
