When /^I confirm table cell deletion$/ do
  wait_for_nothing_to_be_animating
  touch "view:'UITableViewCellDeleteConfirmationButton'"
  wait_for_nothing_to_be_animating
end

When /^I touch the delete edit control for the table view cell "([^"]*)"$/ do |tvc_mark|
  delete_control_selector = "view:'UITableViewCell' view marked:'#{tvc_mark}' parent view:'UITableViewCell' view:'UITableViewCellEditControl'" 
  touch delete_control_selector
end

When /^I should see the confirm deletion button$/ do
    check_element_exists_and_is_visible("view:'UITableViewCellDeleteConfirmationButton'")
end

When /^I should not see the confirm deletion button$/ do
    check_element_does_not_exist_or_is_not_visible("view:'UITableViewCellDeleteConfirmationButton'")
end

Then /^I should not see an "(.*?)" button$/ do |button_mark|
    check_element_does_not_exist_or_is_not_visible("button marked:'#{button_mark}'")
end

Then /^I should see an "(.*?)" button$/ do |button_mark|
    check_element_exists_and_is_visible("button marked:'#{button_mark}'")
end

Then /^I should not see a "(.*?)" button$/ do |button_mark|
    check_element_does_not_exist_or_is_not_visible("button marked:'#{button_mark}'")
end

Then(/^"(.*?)" should be scrolled off the top of the screen$/) do |label_mark|
  accessibility_frame("view:'UITableViewCell' view marked:'#{label_mark}").y.should be < 0
end

Then(/^"(.*?)" should be scrolled off the left of the screen$/) do |label_mark|
  frame = accessibility_frame("view:'UITableViewCell' view marked:'#{label_mark}")
  right = frame.x + frame.width
  right.should be <= 0
end

Then(/^"(.*?)" should be visible on screen$/) do |label_mark|
  accessibility_frame("view:'UITableViewCell' view marked:'#{label_mark}").y.should be >= 0
end
