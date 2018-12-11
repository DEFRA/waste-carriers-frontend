# Change Log

## [v2.4.5](https://github.com/DEFRA/waste-carriers-frontend/tree/v2.4.5) (2018-11-20)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v2.4.4...v2.4.5)

**Merged pull requests:**

- Use NCCC default for AD accountEmail instead of individual emails [\#177](https://github.com/DEFRA/waste-carriers-frontend/pull/177) ([irisfaraway](https://github.com/irisfaraway))

## [v2.4.4](https://github.com/DEFRA/waste-carriers-frontend/tree/v2.4.4) (2018-11-09)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v2.4.3...v2.4.4)

**Implemented enhancements:**

- Add link to transfer a registration to different account [\#176](https://github.com/DEFRA/waste-carriers-frontend/pull/176) ([irisfaraway](https://github.com/irisfaraway))
- Add standard rubocop config to project [\#173](https://github.com/DEFRA/waste-carriers-frontend/pull/173) ([Cruikshanks](https://github.com/Cruikshanks))
- Add a grace window for expired regs to renew [\#172](https://github.com/DEFRA/waste-carriers-frontend/pull/172) ([Cruikshanks](https://github.com/Cruikshanks))

**Fixed bugs:**

- Fix broken grace window check in CanBeRenewed [\#175](https://github.com/DEFRA/waste-carriers-frontend/pull/175) ([Cruikshanks](https://github.com/Cruikshanks))
- Add missing grace window to example .env file [\#174](https://github.com/DEFRA/waste-carriers-frontend/pull/174) ([Cruikshanks](https://github.com/Cruikshanks))
- Update default renewal window to match current [\#171](https://github.com/DEFRA/waste-carriers-frontend/pull/171) ([Cruikshanks](https://github.com/Cruikshanks))
- Fix expired regs not found when trying to renew [\#170](https://github.com/DEFRA/waste-carriers-frontend/pull/170) ([Cruikshanks](https://github.com/Cruikshanks))

## [v2.4.3](https://github.com/DEFRA/waste-carriers-frontend/tree/v2.4.3) (2018-10-17)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v2.4.2...v2.4.3)

**Implemented enhancements:**

- Remove the access code feature for assisted digital [\#167](https://github.com/DEFRA/waste-carriers-frontend/pull/167) ([Cruikshanks](https://github.com/Cruikshanks))

**Fixed bugs:**

- Fix some business type content in declaration [\#169](https://github.com/DEFRA/waste-carriers-frontend/pull/169) ([Cruikshanks](https://github.com/Cruikshanks))
- Update business types in locales to add missing [\#168](https://github.com/DEFRA/waste-carriers-frontend/pull/168) ([Cruikshanks](https://github.com/Cruikshanks))

## [v2.4.2](https://github.com/DEFRA/waste-carriers-frontend/tree/v2.4.2) (2018-09-25)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v2.4.1...v2.4.2)

**Implemented enhancements:**

- Display account\_email for registrations in NCCC dashboard [\#165](https://github.com/DEFRA/waste-carriers-frontend/pull/165) ([irisfaraway](https://github.com/irisfaraway))

**Fixed bugs:**

- Inaccurate "new or renew registration" link in existing backend [\#166](https://github.com/DEFRA/waste-carriers-frontend/pull/166) ([irisfaraway](https://github.com/irisfaraway))

## [v2.4.1](https://github.com/DEFRA/waste-carriers-frontend/tree/v2.4.1) (2018-09-14)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v2.4...v2.4.1)

**Implemented enhancements:**

- Add CHANGELOG to the project [\#163](https://github.com/DEFRA/waste-carriers-frontend/pull/163) ([Cruikshanks](https://github.com/Cruikshanks))

**Fixed bugs:**

- Remove change account email from admin screen [\#164](https://github.com/DEFRA/waste-carriers-frontend/pull/164) ([Cruikshanks](https://github.com/Cruikshanks))
- Fix broken renew link in back office [\#162](https://github.com/DEFRA/waste-carriers-frontend/pull/162) ([Cruikshanks](https://github.com/Cruikshanks))

## [v2.4](https://github.com/DEFRA/waste-carriers-frontend/tree/v2.4) (2018-09-10)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v2.3.2-beta...v2.4)

**Implemented enhancements:**

- Add rake task to purge both databases [\#156](https://github.com/DEFRA/waste-carriers-frontend/pull/156) ([Cruikshanks](https://github.com/Cruikshanks))
- Add rake task to test mongodb connection [\#153](https://github.com/DEFRA/waste-carriers-frontend/pull/153) ([Cruikshanks](https://github.com/Cruikshanks))
- Add specific support for ELB health check calls [\#148](https://github.com/DEFRA/waste-carriers-frontend/pull/148) ([Cruikshanks](https://github.com/Cruikshanks))
- Set secret\_key\_base when run under prod & rake [\#144](https://github.com/DEFRA/waste-carriers-frontend/pull/144) ([Cruikshanks](https://github.com/Cruikshanks))
- Add Passenger web app server to project [\#142](https://github.com/DEFRA/waste-carriers-frontend/pull/142) ([Cruikshanks](https://github.com/Cruikshanks))
- Update endpoints for various calls to WCR services [\#132](https://github.com/DEFRA/waste-carriers-frontend/pull/132) ([Cruikshanks](https://github.com/Cruikshanks))
- Update project to support connecting to MongoDb 3.6 [\#127](https://github.com/DEFRA/waste-carriers-frontend/pull/127) ([Cruikshanks](https://github.com/Cruikshanks))

**Fixed bugs:**

- Fix missing GOV.UK logo in emails [\#161](https://github.com/DEFRA/waste-carriers-frontend/pull/161) ([Cruikshanks](https://github.com/Cruikshanks))
- Fix renewals url for back office [\#160](https://github.com/DEFRA/waste-carriers-frontend/pull/160) ([Cruikshanks](https://github.com/Cruikshanks))
- Update renewal hold fix to not mess with env var [\#159](https://github.com/DEFRA/waste-carriers-frontend/pull/159) ([Cruikshanks](https://github.com/Cruikshanks))
- Fix broken logic for renewals holding page [\#158](https://github.com/DEFRA/waste-carriers-frontend/pull/158) ([Cruikshanks](https://github.com/Cruikshanks))
- Do not raise error on Mongoid document not found [\#155](https://github.com/DEFRA/waste-carriers-frontend/pull/155) ([Cruikshanks](https://github.com/Cruikshanks))
- Remove hard coded use of service email values [\#154](https://github.com/DEFRA/waste-carriers-frontend/pull/154) ([Cruikshanks](https://github.com/Cruikshanks))
- Fix missing assets by not setting asset\_host [\#152](https://github.com/DEFRA/waste-carriers-frontend/pull/152) ([Cruikshanks](https://github.com/Cruikshanks))
- Simplify the setting of urls in application.rb [\#151](https://github.com/DEFRA/waste-carriers-frontend/pull/151) ([Cruikshanks](https://github.com/Cruikshanks))
- Fix Perf. test rake task breaking cap deploy [\#147](https://github.com/DEFRA/waste-carriers-frontend/pull/147) ([Cruikshanks](https://github.com/Cruikshanks))
- Fix CI reporter rake task breaking cap deploy [\#146](https://github.com/DEFRA/waste-carriers-frontend/pull/146) ([Cruikshanks](https://github.com/Cruikshanks))
- Move renewal root path to logic not env var [\#145](https://github.com/DEFRA/waste-carriers-frontend/pull/145) ([Cruikshanks](https://github.com/Cruikshanks))
- Ignore Passengerfile.json [\#143](https://github.com/DEFRA/waste-carriers-frontend/pull/143) ([Cruikshanks](https://github.com/Cruikshanks))
- Refactor mongoid config to use URI's [\#141](https://github.com/DEFRA/waste-carriers-frontend/pull/141) ([Cruikshanks](https://github.com/Cruikshanks))
- Update to support using mock worldpay service [\#140](https://github.com/DEFRA/waste-carriers-frontend/pull/140) ([Cruikshanks](https://github.com/Cruikshanks))
- Resolve issues with config found in testing [\#139](https://github.com/DEFRA/waste-carriers-frontend/pull/139) ([Cruikshanks](https://github.com/Cruikshanks))
- Standardise environment variables [\#138](https://github.com/DEFRA/waste-carriers-frontend/pull/138) ([Cruikshanks](https://github.com/Cruikshanks))
- Fix broken conviction check after reg edit [\#137](https://github.com/DEFRA/waste-carriers-frontend/pull/137) ([Cruikshanks](https://github.com/Cruikshanks))
- Update url for address lookup [\#136](https://github.com/DEFRA/waste-carriers-frontend/pull/136) ([Cruikshanks](https://github.com/Cruikshanks))
- Update default ports used for services [\#135](https://github.com/DEFRA/waste-carriers-frontend/pull/135) ([Cruikshanks](https://github.com/Cruikshanks))
- Remove references and dependencies on elasticsearch [\#134](https://github.com/DEFRA/waste-carriers-frontend/pull/134) ([Cruikshanks](https://github.com/Cruikshanks))
- Fix broken rake by upgrading Rspec [\#131](https://github.com/DEFRA/waste-carriers-frontend/pull/131) ([Cruikshanks](https://github.com/Cruikshanks))
- Synch secret key base & devise init. with renewals [\#130](https://github.com/DEFRA/waste-carriers-frontend/pull/130) ([Cruikshanks](https://github.com/Cruikshanks))
- Upgrade service to 2.4.2 to match wcr renewals [\#129](https://github.com/DEFRA/waste-carriers-frontend/pull/129) ([Cruikshanks](https://github.com/Cruikshanks))

**Merged pull requests:**

- Assisted digital renewals are routed incorrectly [\#157](https://github.com/DEFRA/waste-carriers-frontend/pull/157) ([irisfaraway](https://github.com/irisfaraway))
- Update email settings and add test email rake task [\#150](https://github.com/DEFRA/waste-carriers-frontend/pull/150) ([Cruikshanks](https://github.com/Cruikshanks))
- Rewrite frontend seeding of users [\#149](https://github.com/DEFRA/waste-carriers-frontend/pull/149) ([irisfaraway](https://github.com/irisfaraway))
- Update month stated in renewals holding page [\#133](https://github.com/DEFRA/waste-carriers-frontend/pull/133) ([Cruikshanks](https://github.com/Cruikshanks))
- Fix README details and defaults for services [\#128](https://github.com/DEFRA/waste-carriers-frontend/pull/128) ([Cruikshanks](https://github.com/Cruikshanks))

## [v2.3.2-beta](https://github.com/DEFRA/waste-carriers-frontend/tree/v2.3.2-beta) (2018-03-21)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v2.3.1...v2.3.2-beta)

**Implemented enhancements:**

- Add link to renew reg. from user signed in page [\#121](https://github.com/DEFRA/waste-carriers-frontend/pull/121) ([Cruikshanks](https://github.com/Cruikshanks))
- Redirect digital renewals to temporary info page [\#120](https://github.com/DEFRA/waste-carriers-frontend/pull/120) ([Cruikshanks](https://github.com/Cruikshanks))
- Check if registration eligible to renew [\#118](https://github.com/DEFRA/waste-carriers-frontend/pull/118) ([Cruikshanks](https://github.com/Cruikshanks))
- Check if IR registration eligible to renew [\#114](https://github.com/DEFRA/waste-carriers-frontend/pull/114) ([Cruikshanks](https://github.com/Cruikshanks))
- Logic to confirm if reg. exists in enter reg. page [\#113](https://github.com/DEFRA/waste-carriers-frontend/pull/113) ([Cruikshanks](https://github.com/Cruikshanks))

**Fixed bugs:**

- Fix or mark PENDING broken feature tests [\#124](https://github.com/DEFRA/waste-carriers-frontend/pull/124) ([Cruikshanks](https://github.com/Cruikshanks))
- Update content CBD renewals service stand in page [\#123](https://github.com/DEFRA/waste-carriers-frontend/pull/123) ([Cruikshanks](https://github.com/Cruikshanks))
- Add VCR cassettes to the project [\#115](https://github.com/DEFRA/waste-carriers-frontend/pull/115) ([Cruikshanks](https://github.com/Cruikshanks))
- Refactor existing\_registration\_ctrl logic [\#111](https://github.com/DEFRA/waste-carriers-frontend/pull/111) ([Cruikshanks](https://github.com/Cruikshanks))
- Fix broken comp. house strike off test [\#110](https://github.com/DEFRA/waste-carriers-frontend/pull/110) ([Cruikshanks](https://github.com/Cruikshanks))
- Fix wrong use of country code from countries gem [\#109](https://github.com/DEFRA/waste-carriers-frontend/pull/109) ([Cruikshanks](https://github.com/Cruikshanks))
- Update Devise account locking config [\#108](https://github.com/DEFRA/waste-carriers-frontend/pull/108) ([irisfaraway](https://github.com/irisfaraway))
- Fix markdown formatting, update GitHub links [\#107](https://github.com/DEFRA/waste-carriers-frontend/pull/107) ([irisfaraway](https://github.com/irisfaraway))

**Merged pull requests:**

- Update master to latest for release 2.3.2-beta [\#126](https://github.com/DEFRA/waste-carriers-frontend/pull/126) ([Cruikshanks](https://github.com/Cruikshanks))
- Update version to 2.3.2-beta prior to release [\#125](https://github.com/DEFRA/waste-carriers-frontend/pull/125) ([Cruikshanks](https://github.com/Cruikshanks))
- Temp/expiry tests [\#117](https://github.com/DEFRA/waste-carriers-frontend/pull/117) ([irisfaraway](https://github.com/irisfaraway))
- Fix dates in test for renewable-from date [\#116](https://github.com/DEFRA/waste-carriers-frontend/pull/116) ([irisfaraway](https://github.com/irisfaraway))
- Change date of OS Places terms to 20 December [\#104](https://github.com/DEFRA/waste-carriers-frontend/pull/104) ([lewispb](https://github.com/lewispb))

## [v2.3.1](https://github.com/DEFRA/waste-carriers-frontend/tree/v2.3.1) (2016-12-19)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v2.3.0...v2.3.1)

**Fixed bugs:**

- Simplecov creating files with very long path names [\#102](https://github.com/DEFRA/waste-carriers-frontend/issues/102)

**Closed issues:**

- Create a cron job to clear Redis every night at 2.30 a.m. [\#95](https://github.com/DEFRA/waste-carriers-frontend/issues/95)
- Implement rails config gem, use settings.yml [\#23](https://github.com/DEFRA/waste-carriers-frontend/issues/23)

**Merged pull requests:**

- Add OS address copyright link, page and test [\#103](https://github.com/DEFRA/waste-carriers-frontend/pull/103) ([lewispb](https://github.com/lewispb))
- Resolve two "pending" steps in the Cucumber suite [\#100](https://github.com/DEFRA/waste-carriers-frontend/pull/100) ([TThurston](https://github.com/TThurston))
- Allow companies in "voluntary arrangement" status to register [\#99](https://github.com/DEFRA/waste-carriers-frontend/pull/99) ([TThurston](https://github.com/TThurston))
- Remove debugging output in footer partial [\#98](https://github.com/DEFRA/waste-carriers-frontend/pull/98) ([TThurston](https://github.com/TThurston))
- Fix WorldPay help errors when registration has no account email [\#97](https://github.com/DEFRA/waste-carriers-frontend/pull/97) ([TThurston](https://github.com/TThurston))

## [v2.3.0](https://github.com/DEFRA/waste-carriers-frontend/tree/v2.3.0) (2016-10-24)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v2.2.2-beta...v2.3.0)

**Merged pull requests:**

- Create a banner to warn about nightly downtime [\#94](https://github.com/DEFRA/waste-carriers-frontend/pull/94) ([lewispb](https://github.com/lewispb))
- Fix worldpay refusal redirection [\#93](https://github.com/DEFRA/waste-carriers-frontend/pull/93) ([lewispb](https://github.com/lewispb))
- Ensure order type param is set for worldpay cancellation [\#92](https://github.com/DEFRA/waste-carriers-frontend/pull/92) ([lewispb](https://github.com/lewispb))
- Test that Redis is available before each page load [\#91](https://github.com/DEFRA/waste-carriers-frontend/pull/91) ([lewispb](https://github.com/lewispb))
- Stop \(ab\)using the session [\#90](https://github.com/DEFRA/waste-carriers-frontend/pull/90) ([lewispb](https://github.com/lewispb))

## [v2.2.2-beta](https://github.com/DEFRA/waste-carriers-frontend/tree/v2.2.2-beta) (2016-09-12)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v2.2.1-beta...v2.2.2-beta)

**Closed issues:**

- Set additional Airbrake options [\#78](https://github.com/DEFRA/waste-carriers-frontend/issues/78)
- Upgrade Ruby / Rails version [\#5](https://github.com/DEFRA/waste-carriers-frontend/issues/5)

**Merged pull requests:**

- Don't show certificates for a registration in the "refused" state [\#88](https://github.com/DEFRA/waste-carriers-frontend/pull/88) ([TThurston](https://github.com/TThurston))
- Persist edits to lower-tier registrations [\#87](https://github.com/DEFRA/waste-carriers-frontend/pull/87) ([TThurston](https://github.com/TThurston))

## [v2.2.1-beta](https://github.com/DEFRA/waste-carriers-frontend/tree/v2.2.1-beta) (2016-08-19)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v2.2.0-beta...v2.2.1-beta)

**Merged pull requests:**

- Improve handling of the "free edit" exploit. [\#86](https://github.com/DEFRA/waste-carriers-frontend/pull/86) ([TThurston](https://github.com/TThurston))
- Improve error handling, reducing Errbit diversity hopefully [\#85](https://github.com/DEFRA/waste-carriers-frontend/pull/85) ([TThurston](https://github.com/TThurston))
- Cache the Registration Order object in the New Configuration view [\#84](https://github.com/DEFRA/waste-carriers-frontend/pull/84) ([TThurston](https://github.com/TThurston))
- Block orders which have a total cost of £0 [\#83](https://github.com/DEFRA/waste-carriers-frontend/pull/83) ([TThurston](https://github.com/TThurston))
- Tweak Airbrake exception logging [\#82](https://github.com/DEFRA/waste-carriers-frontend/pull/82) ([TThurston](https://github.com/TThurston))
- Feature/misc tidy [\#81](https://github.com/DEFRA/waste-carriers-frontend/pull/81) ([TThurston](https://github.com/TThurston))
- Allow digital users to make assisted-digital payment [\#80](https://github.com/DEFRA/waste-carriers-frontend/pull/80) ([TThurston](https://github.com/TThurston))
- Bank transfer email working [\#79](https://github.com/DEFRA/waste-carriers-frontend/pull/79) ([TThurston](https://github.com/TThurston))
- Rescue exceptions inside export to csv loop [\#67](https://github.com/DEFRA/waste-carriers-frontend/pull/67) ([lewispb](https://github.com/lewispb))

## [v2.2.0-beta](https://github.com/DEFRA/waste-carriers-frontend/tree/v2.2.0-beta) (2016-07-27)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v2.1.2-beta_irdecom...v2.2.0-beta)

**Fixed bugs:**

- Precompile print css [\#71](https://github.com/DEFRA/waste-carriers-frontend/pull/71) ([lewispb](https://github.com/lewispb))
- Remove special and broken page title from 500 page [\#40](https://github.com/DEFRA/waste-carriers-frontend/pull/40) ([lewispb](https://github.com/lewispb))
- Refactor wording logic on editRenewComplete [\#39](https://github.com/DEFRA/waste-carriers-frontend/pull/39) ([lewispb](https://github.com/lewispb))
- Fix edit-caused-new wording charge on confirmation [\#38](https://github.com/DEFRA/waste-carriers-frontend/pull/38) ([lewispb](https://github.com/lewispb))
- Resolve issue displaying edit wording incorrectly [\#37](https://github.com/DEFRA/waste-carriers-frontend/pull/37) ([lewispb](https://github.com/lewispb))
- Add copy cards to order builder [\#36](https://github.com/DEFRA/waste-carriers-frontend/pull/36) ([lewispb](https://github.com/lewispb))
- View certificate in new tab, prevent layout issue [\#34](https://github.com/DEFRA/waste-carriers-frontend/pull/34) ([lewispb](https://github.com/lewispb))
- Show correct wording on order complete page [\#33](https://github.com/DEFRA/waste-carriers-frontend/pull/33) ([lewispb](https://github.com/lewispb))

**Closed issues:**

- PUTing a Registration to the Services over-writes payments [\#43](https://github.com/DEFRA/waste-carriers-frontend/issues/43)
- Separate test and development databases [\#16](https://github.com/DEFRA/waste-carriers-frontend/issues/16)
- Cucumber test suite does not pass unless Rails server is running locally [\#15](https://github.com/DEFRA/waste-carriers-frontend/issues/15)

**Merged pull requests:**

- Update "UK company number" validation rules [\#77](https://github.com/DEFRA/waste-carriers-frontend/pull/77) ([TThurston](https://github.com/TThurston))
- Change behaviour of Company Number for foreign companies [\#76](https://github.com/DEFRA/waste-carriers-frontend/pull/76) ([TThurston](https://github.com/TThurston))
- Add instructions to NCCC screen for Update Account Email [\#75](https://github.com/DEFRA/waste-carriers-frontend/pull/75) ([TThurston](https://github.com/TThurston))
- Improve key person validations [\#73](https://github.com/DEFRA/waste-carriers-frontend/pull/73) ([lewispb](https://github.com/lewispb))
- Tweak project to use MailCatcher rather than LetterOpener [\#72](https://github.com/DEFRA/waste-carriers-frontend/pull/72) ([TThurston](https://github.com/TThurston))
- Upgrade ruby and rails [\#70](https://github.com/DEFRA/waste-carriers-frontend/pull/70) ([TThurston](https://github.com/TThurston))
- Extend integration test to cover "overpayment should activate" requirement [\#69](https://github.com/DEFRA/waste-carriers-frontend/pull/69) ([TThurston](https://github.com/TThurston))
- Correct IBAN and SWIFTBAC typos [\#68](https://github.com/DEFRA/waste-carriers-frontend/pull/68) ([TThurston](https://github.com/TThurston))
- Show flash message when updating account email [\#66](https://github.com/DEFRA/waste-carriers-frontend/pull/66) ([lewispb](https://github.com/lewispb))
- Fix incorrectly handling of expiry date format [\#65](https://github.com/DEFRA/waste-carriers-frontend/pull/65) ([TThurston](https://github.com/TThurston))
- Fix IR renewal expiry date submission [\#59](https://github.com/DEFRA/waste-carriers-frontend/pull/59) ([lewispb](https://github.com/lewispb))
- Always open certificates in new tab [\#56](https://github.com/DEFRA/waste-carriers-frontend/pull/56) ([lewispb](https://github.com/lewispb))
- Filter Warden info from Airbake [\#55](https://github.com/DEFRA/waste-carriers-frontend/pull/55) ([TThurston](https://github.com/TThurston))
- Handle "IR Renewal Number Not Found" response from services [\#53](https://github.com/DEFRA/waste-carriers-frontend/pull/53) ([TThurston](https://github.com/TThurston))
- Reset copy card quantity to zero for every new order. [\#52](https://github.com/DEFRA/waste-carriers-frontend/pull/52) ([TThurston](https://github.com/TThurston))
- Always open "Certificate" page in a new tab. [\#51](https://github.com/DEFRA/waste-carriers-frontend/pull/51) ([TThurston](https://github.com/TThurston))
- Tweak two elements of order handling... [\#50](https://github.com/DEFRA/waste-carriers-frontend/pull/50) ([TThurston](https://github.com/TThurston))
- Editing a renewed registration does not apply renewal charge [\#49](https://github.com/DEFRA/waste-carriers-frontend/pull/49) ([lewispb](https://github.com/lewispb))
- Fix wording on confirmation page for expired renewals [\#47](https://github.com/DEFRA/waste-carriers-frontend/pull/47) ([lewispb](https://github.com/lewispb))
- Use thin with capybara [\#45](https://github.com/DEFRA/waste-carriers-frontend/pull/45) ([lewispb](https://github.com/lewispb))
- Apply charged edits when payment method is selected [\#44](https://github.com/DEFRA/waste-carriers-frontend/pull/44) ([lewispb](https://github.com/lewispb))
- Extend the Cucumber test for renewing an expired IR registration [\#41](https://github.com/DEFRA/waste-carriers-frontend/pull/41) ([TThurston](https://github.com/TThurston))
- Resolve Passenger call errors in Airbrake \(hopefully\) [\#35](https://github.com/DEFRA/waste-carriers-frontend/pull/35) ([lewispb](https://github.com/lewispb))
- Update date-of-birth validation rules [\#31](https://github.com/DEFRA/waste-carriers-frontend/pull/31) ([TThurston](https://github.com/TThurston))
- Filter personal- and security-related information from the fields we record in Airbrake [\#30](https://github.com/DEFRA/waste-carriers-frontend/pull/30) ([TThurston](https://github.com/TThurston))
- Filter passwords in params before going to Airbrake [\#29](https://github.com/DEFRA/waste-carriers-frontend/pull/29) ([lewispb](https://github.com/lewispb))
- Update confirmation screen wording and add tests [\#28](https://github.com/DEFRA/waste-carriers-frontend/pull/28) ([lewispb](https://github.com/lewispb))
- Finance handling [\#27](https://github.com/DEFRA/waste-carriers-frontend/pull/27) ([lewispb](https://github.com/lewispb))
- Miscellaneous code tidy and development enhancements [\#26](https://github.com/DEFRA/waste-carriers-frontend/pull/26) ([TThurston](https://github.com/TThurston))
- Remove risk of logging personal information, and tweak log severity levels [\#25](https://github.com/DEFRA/waste-carriers-frontend/pull/25) ([TThurston](https://github.com/TThurston))
- Refactor order models [\#22](https://github.com/DEFRA/waste-carriers-frontend/pull/22) ([lewispb](https://github.com/lewispb))
- Add colour to registration index [\#21](https://github.com/DEFRA/waste-carriers-frontend/pull/21) ([lewispb](https://github.com/lewispb))
- Attach a PDF of the certifcate to welcome email [\#20](https://github.com/DEFRA/waste-carriers-frontend/pull/20) ([lewispb](https://github.com/lewispb))
- Bring in 'Kev's tests' from an old branch [\#19](https://github.com/DEFRA/waste-carriers-frontend/pull/19) ([lewispb](https://github.com/lewispb))
- Rename delete to de-register [\#18](https://github.com/DEFRA/waste-carriers-frontend/pull/18) ([lewispb](https://github.com/lewispb))
- Update the deployment script to capture coverage reports in Jenkins [\#17](https://github.com/DEFRA/waste-carriers-frontend/pull/17) ([TThurston](https://github.com/TThurston))
- Add Rcov plugin to simplecov and configure [\#13](https://github.com/DEFRA/waste-carriers-frontend/pull/13) ([lewispb](https://github.com/lewispb))
- Update Airbrake gem version [\#12](https://github.com/DEFRA/waste-carriers-frontend/pull/12) ([lewispb](https://github.com/lewispb))
- Use Thin instead of Webrick for our dev server [\#11](https://github.com/DEFRA/waste-carriers-frontend/pull/11) ([lewispb](https://github.com/lewispb))
- Add the dotenv gem to manage development environment variables [\#10](https://github.com/DEFRA/waste-carriers-frontend/pull/10) ([lewispb](https://github.com/lewispb))
- Quieten the assets log in the server console [\#9](https://github.com/DEFRA/waste-carriers-frontend/pull/9) ([lewispb](https://github.com/lewispb))
- After logging audit, remove personal info from logging [\#8](https://github.com/DEFRA/waste-carriers-frontend/pull/8) ([lewispb](https://github.com/lewispb))
- Add awesome print and better errors gems [\#7](https://github.com/DEFRA/waste-carriers-frontend/pull/7) ([lewispb](https://github.com/lewispb))
- Add support for Airbrake-based exception logging [\#6](https://github.com/DEFRA/waste-carriers-frontend/pull/6) ([TThurston](https://github.com/TThurston))
- Add simplecov to report code test coverage [\#3](https://github.com/DEFRA/waste-carriers-frontend/pull/3) ([lewispb](https://github.com/lewispb))

## [v2.1.2-beta_irdecom](https://github.com/DEFRA/waste-carriers-frontend/tree/v2.1.2-beta_irdecom) (2016-05-11)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v2.1.2-beta...v2.1.2-beta_irdecom)

**Merged pull requests:**

- Stop ignoring .rspec and set color flag [\#4](https://github.com/DEFRA/waste-carriers-frontend/pull/4) ([lewispb](https://github.com/lewispb))
- Hotfix/export logging [\#2](https://github.com/DEFRA/waste-carriers-frontend/pull/2) ([woolysammoth](https://github.com/woolysammoth))

## [v2.1.2-beta](https://github.com/DEFRA/waste-carriers-frontend/tree/v2.1.2-beta) (2015-06-17)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v2.1.1-beta...v2.1.2-beta)

## [v2.1.1-beta](https://github.com/DEFRA/waste-carriers-frontend/tree/v2.1.1-beta) (2015-06-02)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v2.1-beta...v2.1.1-beta)

## [v2.1-beta](https://github.com/DEFRA/waste-carriers-frontend/tree/v2.1-beta) (2015-05-26)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v2.0.4-beta...v2.1-beta)

## [v2.0.4-beta](https://github.com/DEFRA/waste-carriers-frontend/tree/v2.0.4-beta) (2015-05-12)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v2.0.3-beta...v2.0.4-beta)

## [v2.0.3-beta](https://github.com/DEFRA/waste-carriers-frontend/tree/v2.0.3-beta) (2015-05-05)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v2.0.2-beta...v2.0.3-beta)

## [v2.0.2-beta](https://github.com/DEFRA/waste-carriers-frontend/tree/v2.0.2-beta) (2015-04-13)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v2.0.1-beta...v2.0.2-beta)

## [v2.0.1-beta](https://github.com/DEFRA/waste-carriers-frontend/tree/v2.0.1-beta) (2015-04-13)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v2.0-beta...v2.0.1-beta)

## [v2.0-beta](https://github.com/DEFRA/waste-carriers-frontend/tree/v2.0-beta) (2015-03-26)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v1.1.3...v2.0-beta)

## [v1.1.3](https://github.com/DEFRA/waste-carriers-frontend/tree/v1.1.3) (2014-11-27)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v1.1.2...v1.1.3)

## [v1.1.2](https://github.com/DEFRA/waste-carriers-frontend/tree/v1.1.2) (2014-05-23)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v1.1.1...v1.1.2)

## [v1.1.1](https://github.com/DEFRA/waste-carriers-frontend/tree/v1.1.1) (2014-04-02)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v1.1.0...v1.1.1)

**Merged pull requests:**

- Upgrade Stageprompt to version 2.1.0 [\#1](https://github.com/DEFRA/waste-carriers-frontend/pull/1) ([robyoung](https://github.com/robyoung))

## [v1.1.0](https://github.com/DEFRA/waste-carriers-frontend/tree/v1.1.0) (2014-01-21)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v1.0.1...v1.1.0)

## [v1.0.1](https://github.com/DEFRA/waste-carriers-frontend/tree/v1.0.1) (2013-12-20)
[Full Changelog](https://github.com/DEFRA/waste-carriers-frontend/compare/v1.0.0...v1.0.1)

## [v1.0.0](https://github.com/DEFRA/waste-carriers-frontend/tree/v1.0.0) (2013-12-13)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*