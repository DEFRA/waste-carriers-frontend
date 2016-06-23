require 'objspace'

World(ShowMeTheCookies)

AfterStep do |scenario|

  if ENV['PRINT_CUCUMBER_COOKIE_SIZE']

    cookies_size = get_me_the_cookies.to_s.bytesize
    #print "#{cookies_size} byte cookie".light_blue
    if cookies_size > 2000
      print 'WARNING: LARGE COOKIE'.red
      sleep 5
    end

  end

end
