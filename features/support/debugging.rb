After do |scenario|
  if scenario.failed?
    begin
      save_and_open_page
    rescue Exception=>e
      # handle e
      puts ''
      puts 'Error trying to open browser: ' + e.to_s
      puts 'EXCEPTION:: URL of the page with the test failure: '+page.current_path.to_s
      puts ''
      print page.html
    end
  end
end