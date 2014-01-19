Feature:
	In order to write automated acceptance tests
	As a tester
	I want to be able to automate alert views

Background:
	Given I launch the app
	And I am have navigated to the "UIAlertView" section

Scenario Outline: Showing and dismissing the Alert View
	Given the device is in <orientation> orientation
  And I wait for nothing to be animating

	When I touch "Show UIAlertView"
	Then I should see "AlertView Title"
	And I should see "Button1"
	And I should see "Button 2"

	When I touch the alert view's "Ok" button
    And I wait for nothing to be animating
	Then I should not see "AlertView Title"
	And I should not see "Button1"
	And I should not see "Button 2"

Examples:
  | orientation | 
	| portrait    |
	| landscape   |


