class RenewalExtensionController < ApplicationController
  include RegistrationsHelper

  def show
    return unless @registration
  end
end
