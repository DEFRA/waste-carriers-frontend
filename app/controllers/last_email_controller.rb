# frozen_string_literal: true

class LastEmailController < ApplicationController
  def show
    render json: LastEmailCache.instance.last_email_json
  end
end
