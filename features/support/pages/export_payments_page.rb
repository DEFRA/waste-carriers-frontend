# Helper used in testing for working with the payments export page.
module ExportPaymentsPage
  def go_to_payments_page_directly
    visit payments_search_path
  end

  def verify_payments_export_page_visible()
    find_by_id('report_from')
  end
end
World(ExportPaymentsPage)
