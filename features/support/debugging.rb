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
      if current_email
        begin
          current_email.save_and_open
        rescue Exception=>e
          puts ''
          puts 'Could not open email in browser, printing to console: ' + e.to_s
          puts ''
          print current_email.body
        end
      end
    end
  end
  # Force clear emails to ensure no emails from other tests are shown in subsequent tests
  clear_emails
end