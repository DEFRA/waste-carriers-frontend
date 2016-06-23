require 'objspace'

World(ShowMeTheCookies)

After do |scenario|

  if ENV['PRINT_CUCUMBER_COOKIE_SIZE']

    cookies_size = get_me_the_cookies.to_s.bytesize
    print "#{cookies_size} byte cookie".light_blue
    print 'WARNING: LARGE COOKIE'.red if cookies_size > 4000

  end

end
