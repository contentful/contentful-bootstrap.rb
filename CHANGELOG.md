# Change Log

## Unreleased
## v3.12.0
### Added
* Added logging for publishing actions. [#71](https://github.com/contentful/contentful-bootstrap.rb/pull/71)

## v3.11.1
### Fixed
* Fixed array importing. [#70](https://github.com/contentful/contentful-bootstrap.rb/pull/70)

## v3.11.0
### Added
* Added `--environment` support to `update_space` and `generate_json`.

### Changed
* Updated to the new CMA and CDA SDK versions.

## v3.10.0
### Added
* Added `--content-type-ids` filter to `generate_json` command to allow selecting which content types to import.

## v3.9.1
### Fixed
* Fixed an issue in which assets save as `Contentful::Management::File` objects instead of as JSON when using `--mark-processed`.

## v3.9.0
### Fixed
* Fixed `quiet` not being forwarded properly to `generate_json` and `update_space`
* Fixed `X-Contentful-User-Agent` headers now use `application` instead of `integration` header.

### Added
* Added `--use-preview` flag to `generate_json` command [#62](https://github.com/contentful/contentful-bootstrap.rb/issues/62)
* Added `--no-publish` flag to `create_space` and `update_space` commands [#62](https://github.com/contentful/contentful-bootstrap.rb/issues/62)

### Changed
* `generate_json` now imports all available content in your space [#62](https://github.com/contentful/contentful-bootstrap.rb/issues/62)
* Assets can now be updated when using `update_space`.

## v3.8.0
### Changed
* Changed `Contentful::Bootstrap::CreateCommand#organizations` to use the new public `/organizations` endpoint.

## v3.7.0
### Fixed
* Fixed `skip_content_types` option on `update_space` [#59](https://github.com/contentful/contentful-bootstrap.rb/pull/59)

### Added
* Added `--locale` option to `create_space` and `update_space` in order to create Spaces on a locale different to `en-US`

## v3.6.1

### Changed
* Changed User Agent Headers to use the new format
* Updated versions of CMA and CDA SDK to latest available

## v3.5.2

### Fixed
* Fixed compatibility with CDA 2.0.0 SDK

## v3.5.1
### Fixed
* Fixed organization fetching when no organization ID is provided on the configuration file [#54](https://github.com/contentful/contentful-bootstrap.rb/issues/54)

## v3.5.0

### Added
* Add `-q` and `--quiet` flags to the CLI Tool and their respective command classes [#48](https://github.com/contentful/contentful-bootstrap.rb/issues/48)
* Add `:no_input` option to library commands [#48](https://github.com/contentful/contentful-bootstrap.rb/issues/48)

### Changed
* Refactored internals to allow more option flexibility and simplified the `CommandRunner`.
* Updated dependencies to the newest available SDKs

### Fixed
* Fixed Object Field parsing for JSON Templates [#51](https://github.com/contentful/contentful-bootstrap.rb/issues/51)


## v3.4.0
### Added
* Add `-v` and `--version` flags to output current version
* Add possibility to define `CONTENTFUL_ORGANIZATION_ID` in your `.contentfulrc` file [#44](https://github.com/contentful/contentful-bootstrap.rb/issues/44)

## v3.3.0
### Added
* Adds possibility to change `contentType` for Assets [#39](https://github.com/contentful/contentful-bootstrap.rb/issues/39)
* Adds `--content-types-only` option to `generate_json`
* Adds `--skip-content-types` option to `update_space`

### Fixed
* Fixes a bug in built-in templates using obsolete `link_type` properties

## v3.2.0
### Added
* Adds `update_space` command to update already existing spaces using JSON Templates
* Adds `--mark-processed` option to `create_space` and `update_space` to enforce marking which resources have already been processed

## v3.1.1
### Fixed
* Fixes a bug where `display_field` was not properly populated when being generated from JSON templates [#35](https://github.com/contentful/contentful-bootstrap.rb/issues/35)

## v3.1.0
### Fixed
* Version Locked Webmock causing all our VCRs to fail
* Version Locked Contentful Management SDK

### Added
* Custom User-Agent header

## v3.0.0
### Changed
* Change JSON Template format to resemble the API more closely
* Create Entries on 2 Steps [#27](https://github.com/contentful-labs/contentful-bootstrap.rb/pull/27)
* Add JSON Template Version Check [#31](https://github.com/contentful-labs/contentful-bootstrap.rb/issues/31)

## v2.0.2
### Fixed
* Array and Link handling

### Changed
* Command now provide better help on incomplete command

## v2.0.1 [YANKED]
### Changed
* Scoped File Usage on GenerateJson Command

## v2.0.0 [YANKED]
### Changed
* Refactored `Commands` into new classes
* Renamed `Commands` to `CommandRunner`, kept external interface, moved internal logic to new `Commands` classes
* Refactored `Token` to be an Object instead of a collection of static behavior
* General code refactoring and cleanup

### Added
* More robust mechanism for waiting on processed assets
* JSON Template generator `generate_json` command
* Added Specs for almost all the code
* Applied Rubocop Style guide

## v1.6.0
### Added
* Support for Symbols in Array fields
* Support for Links of other Entries that are not yet saved

## v1.5.1
### Fixed
* Array fields were getting overwritten with `nil`

## v1.5.0
### Added
* Multiple Organization ID fetch

## v1.4.0
### Added
* Contentful Space URL after creation
* Support for Array fields in JSON Templates

## v1.3.2
### Added
* Error out when no STDIN is detected

## v1.3.1
### Fixed
* Fix help messages. [#5](https://github.com/contentful-labs/contentful-bootstrap.rb/issues/5)

## v1.3.0
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
