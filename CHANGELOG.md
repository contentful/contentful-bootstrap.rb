# Change Log
## Unreleased
### Added
* Spaces now get their own section in `~/.contentfulrc`

### Changed
* Delivery API Tokens now saved per Space

## v1.2.0
### Added
* JSON Template Parser
* `catalogue.json` Template Example

### Changed
* Changed existing templates from using `Symbol` entries as keys to `String`
* Changed command optional parameters to `Hash` to allow better flexibility in commands

## v1.1.0
### Removed
* Removed `init` command as `v1.0.0` refactor removed it's necessity

## v1.0.1 [YANKED]
### Fixed
* Release is now on `master`

## v1.0.0 [YANKED]
### Changed
* Changed namespace from `ContentfulBootstrap` to `Contentful::Bootstrap` to mimic other libraries
* Changed repository name from `contentful_bootstrap.rb` to `contentful-bootstrap.rb` to mimic other libraries
* Delivery API Token will always get created when using `contentful_bootstrap` commands to create a space
* Configuration now read from `~/.contentfulrc`
* Tool now requests user to allow to write configuration files

### Added
* `contentful-bootstrap.rb` version number to API Token description
* `inifile` as runtime dependency
* Add optional `--config CONFIG_PATH` parameter to commands

## v0.0.7
### Fixed
* Redirected Favicon fetch to Contentful's favicon, as some browsers would ping the server indefinitely

## v0.0.6
### Fixed
* Token was not being returned on `generate_token` call

### Added
* `catalogue` template now available
* Added small sleep window between asset processing and publishing


## v0.0.5
### Added
* API Token Generation
* `generate_token` command added to binary
* Better Formatting of current steps
* Space and Access Token Values displayed at end of command

## v0.0.4
### Added
* Added support for users with multiple Organizations
* Added `gallery` template

### Changed
* Removed `deklarativna` dependency
* Removed `sinatra` dependency
* Removed unnecessary `Gemfile.lock` file

## v0.0.3
### Added
* Added `contentful_bootstrap` command
* Added `blog` template

### Fixed
* Fixed Dependencies

## v0.0.2 [YANKED]

## v0.0.1 [YANKED]
