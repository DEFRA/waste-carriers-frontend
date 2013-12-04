# You should edit this file with the browsers you wish to use
# For options, check out http://saucelabs.com/docs/platforms
require "sauce"
require "sauce/capybara"
Sauce.config do |config|
  config[:browsers] = [
#   ["OS", "BROWSER", "VERSION"],
    ["Windows 8", "Internet Explorer", "10"],             
    ["Windows 8", "Firefox", "25"],             
    ["Windows 8", "Chrome", "31"],             
    ["Windows 7", "Internet Explorer", "10"],             
    ["Windows 7", "Internet Explorer", "9"],             
    ["Windows xp", "Internet Explorer", "8"],             
#    ["Windows xp", "Internet Explorer", "6"],             
    ["Windows 7", "Firefox", "20"],
    ["OS X 10.8", "Safari", "6"],                         
    ["OS X 10.8", "Chrome", nil],                         
    ["OS X 10.6", "Safari", "5"],                         
    ["Linux", "Chrome", "30"],          
    ["Linux", "Android", "4.0"]          
  ]
end
