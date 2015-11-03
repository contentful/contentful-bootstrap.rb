# Change Log
## Unreleased
### Changed
* Changed namespace from `ContentfulBootstrap` to `Contentful::Bootstrap` to mimic other libraries
* Changed repository name from `contentful_bootstrap.rb` to `contentful-bootstrap.rb` to mimic other libraries
* Delivery API Token will always get created when using `contentful_bootstrap` commands to create a space

### Added
* `contentful-bootstrap.rb` version number to API Token description

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
