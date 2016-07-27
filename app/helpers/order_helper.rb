module OrderHelper

  def show_copy_cards?(render_type)
    render_type.eql?(Order.new_registration_identifier) ||
      render_type.eql?(Order.renew_registration_identifier) ||
      render_type.eql?(Order.editrenew_caused_new_identifier) ||
      render_type.eql?(Order.extra_copycards_identifier)
  end

end
