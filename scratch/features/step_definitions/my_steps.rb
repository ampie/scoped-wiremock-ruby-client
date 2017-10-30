
require 'calabash-android/cucumber'
require 'calabash-cucumber/operations'
require 'calabash-android/operations'
Given(/^I see an empty login form$/) do

  screenshot_embed
end

When(/^I enter details$/) do
  touch("android.widget.TextView id:'email'")
  keyboard_enter_text('john_smith@gmail.com')
  touch("android.widget.TextView id:'password'")
  keyboard_enter_text ('mysecretpassword')
  screenshot_embed
  touch("android.widget.Button id:'email_sign_in_button'")
end

Then(/^I see the success message$/) do\
  msg='Hello john_smith@gmail.com all the way from the external-rest-service!'
  wait_for_element_exists("* {text CONTAINS[c] '#{msg}'}",{timeout:10})

  screenshot_embed
end
extend(ScopedWireMock::Strategies::ResponseStrategies)
World(ScopedWireMock::Strategies::ResponseStrategies)
extend(ScopedWireMock::Strategies::Requests)
World(ScopedWireMock::Strategies::Requests)