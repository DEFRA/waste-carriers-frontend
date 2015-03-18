module SearchPage
  def search_page_check_search_result_positive(searchTerm)
    visit public_path
    waitForSearchResultsToContainText(
    searchTerm,
      'Showing 1 of 1')
	end

  def search_page_check_search_result_negative(searchTerm)
    visit public_path
    waitForSearchResultsToContainText(
    searchTerm,
      'Showing 0 of 0')
	end
end

World(SearchPage)
