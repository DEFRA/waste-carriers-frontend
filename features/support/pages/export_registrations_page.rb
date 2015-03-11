# Helper used in testing for working with the registrations export page.
module ExportRegistrationsPage
  def go_to_registrations_export_page_directly
    visit registrations_search_path
  end

  def verify_registrations_export_page_visible()
    find_by_id('report_from')
  end
end
World(ExportRegistrationsPage)
