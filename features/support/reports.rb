module Reports
  def open_registrations_export_page_directly()
    go_to_registrations_export_page_directly
  end

  def open_payments_export_page_directly()
    go_to_payments_page_directly
  end

  def check_registrations_export_page_visible()
    verify_registrations_export_page_visible
  end

  def check_payments_export_page_visible()
    verify_payments_export_page_visible
  end
end
World(Reports)
