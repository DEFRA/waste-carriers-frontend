Feature: Discovery
  As a waste-carrier
  I want to discover how to register with the EA
 So that I'm compliant with regulations

 Workflow for the following scenarios can be found at:
 https://docs.google.com/spreadsheets/d/15SbDNrVbwh7nhQoEus-I5mv3RDIW_6nzwyxknUOuAXs/edit?usp=sharing

@happy_day
Scenario Outline: Own waste and no building waste
Given that I'm on the discovery page
And I enter my status as <waste_carrier>
When I tell the system I deal only with my own waste
And I tell the system that I never deal with waste from building or demolition work
Then the system tells me that I must register on the Lower Tier

Examples:
| waste_carrier |
|sole_trader|
|ltd_companyl|
|partnership|
|public_body|

@happy_day
Scenario Outline: Own waste and building waste
Given that I'm on the discovery page
And I enter my status as <waste_carrier>
When I tell the system I deal only with my own waste
And I tell the system that I sometimes deal with waste from building or demolition work
Then the system tells me that I must register on the Upper Tier

Examples:
| waste_carrier |
|sole_trader|
|ltd_companyl|
|partnership|
|public_body|

@happy_day
Scenario Outline: Other waste and main service and animal waste
Given that I'm on the discovery page
And I enter my status as <waste_carrier>
When I tell the system I deal with other waste too
And I tell the system that disposing waste is my main service
And I tell the system  that I only deal with animal, farm and quarry or mine waste
Then the system tells me that I must register on the Lower Tier

Examples:
| waste_carrier |
|sole_trader|
|ltd_companyl|
|partnership|
|public_body|

@happy_day
Scenario Outline: Other waste and main service and no animal waste
Given that I'm on the discovery page
And I enter my status as <waste_carrier>
When I tell the system I deal with other waste too
And I tell the system that disposing waste is my main service
And I tell the system  that I don't deal with animal, farm and quarry or mine waste
Then the system tells me that I must register on the Upper Tier

Examples:
| waste_carrier |
|sole_trader|
|ltd_companyl|
|partnership|
|public_body|

@happy_day
Scenario Outline: Other waste and no main service and building waste
Given that I'm on the discovery page
And I enter my status as <waste_carrier>
When I tell the system I deal with other waste too
And I tell the system that disposing waste is not my main service
And I tell the system  that I sometimes deal with waste from building or demolition work
Then the system tells me that I must register on the Upper Tier

Examples:
| waste_carrier |
|sole_trader|
|ltd_companyl|
|partnership|
|public_body|

@happy_day
Scenario Outline: Other waste and no main service and no building waste
Given that I'm on the discovery page
And I enter my status as <waste_carrier>
When I tell the system I deal with other waste too
And I tell the system that disposing waste is not my main service
And I tell the system  that I never deal with waste from building or demolition work
Then the system tells me that I must register on the Lower Tier

Examples:
| waste_carrier |
|sole_trader|
|ltd_companyl|
|partnership|
|public_body|

@happy_day
Scenario Outline: Charities and authorities
Given that I'm on the discovery page
And I enter my status as <waste_carrier>
Then the system tells me that I must register on the Lower Tier

Examples:
| waste_carrier |
|charity|
|collection_authority|
|regulation_authority|
|disposal_authority|

@happy_day
Scenario: Others
Given that I'm on the discovery page
And I enter my status as 'Other'
Then the system tells me that I must contact EA by phone



Scenario Outline: Back link
Given that I'm on the discovery page
And I enter my status as <waste_carrier>
When I tell the system I deal with other waste too
And I tell the system that disposing waste is my main service
And I tell the system  that I don't deal with animal, farm and quarry or mine waste
And I click on the 'Back Link' twice
Then I see the screen where I told the system I deal with other waste too
And my original choice is still there


Scenario Outline: Back button
Given that I'm on the discovery page
And I enter my status as <waste_carrier>
When I tell the system I deal with other waste too
And I tell the system that disposing waste is my main service
And I tell the system  that I don't deal with animal, farm and quarry or mine waste
And I click on the 'Back Button' twice
Then I see the screen where I told the system I deal with other waste too
And my original choice is still there




