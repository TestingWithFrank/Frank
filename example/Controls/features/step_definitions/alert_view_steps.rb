Then /^I touch the alert view's "(.*?)" button$/ do |button_mark|
  touch "view:'_UIModalItemTableViewCell' marked:'#{button_mark}'"
end
