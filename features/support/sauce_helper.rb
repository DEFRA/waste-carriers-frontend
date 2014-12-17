# You should edit this file with the browsers you wish to use
# For options, check out http://saucelabs.com/docs/platforms
require "sauce"
require "sauce/capybara"
require "sauce/cucumber"

Capybara.default_selector = :xpath

Sauce.config do |config|

  config[:browsers] = [
#   ["OS", "BROWSER", "VERSION"],
    ["Windows 8", "Internet Explorer", "10"],
    ["Windows 7", "Internet Explorer", "9"],
    ["Windows 7", "Internet Explorer", "8"],
    ["Windows 8", "Chrome", "31"],
#    ["Windows 7", "Firefox", "20"],
#    ["OS X 10.8", "Safari", "6"],
    ["Linux", "Chrome", nil]
 ]

 #config[:start_tunnel] = true

end
