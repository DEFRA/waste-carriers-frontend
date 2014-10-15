After do |scenario|
  if scenario.failed?
    if save_and_open_page
      # perform no additional actions
    else
      puts '' if scenario.failed?
      puts 'EXCEPTION:: URL of the page with the test failure: '+page.current_path.to_s if scenario.failed?
      puts '' if scenario.failed?
      print page.html
    end
  end
end