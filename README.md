[![Build Status](https://travis-ci.org/contentful/contentful-bootstrap.rb.svg)](https://travis-ci.org/contentful/contentful-bootstrap.rb)

# Contentful Bootstrap

A small CLI tool for getting started with Contentful

## Contentful
[[Contentful](https://www.contentful.com) provides a content infrastructure for digital teams to power content in websites, apps, and devices. Unlike a CMS, Contentful was built to integrate with the modern software stack. It offers a central hub for structured content, powerful management and delivery APIs, and a customizable web app that enable developers and content creators to ship digital products faster.

## What does `contentful_bootstrap` do?
`contentful_bootstrap` let's you set up a new Contentful environment with a single command.

## How to Use

### Installation

```bash
$ gem install contentful_bootstrap
```

### Usage

You can create spaces by doing:

```bash
$ contentful_bootstrap create_space <space_name> [--template template_name] [--json-template template_path] [--locale locale_code] [--mark-processed] [--no-publish] [--config CONFIG_PATH] [--quiet]
```

You can also generate new Delivery API Tokens by doing:

```bash
$ contentful_bootstrap generate_token <space_id> [--name token_name] [--config CONFIG_PATH] [--quiet]
```

You can also generate JSON Templates from existing spaces by doing:

```bash
$ contentful_bootstrap generate_json <space_id> <delivery_api_access_token> [--environment ENVIRONMENT_ID] [--output-file OUTPUT PATH] [--content-type-ids ct_id_1,ct_id_2] [--content-types-only] [--use-preview] [--quiet]
```

You can update existing spaces from JSON Templates by doing:

```bash
$ contentful_bootstrap update_space <space_id> -j template_path [--environment ENVIRONMENT_ID] [--mark-processed] [--skip-content-types] [--no-publish] [--quiet]
```

### Built-in templates

Just getting started with Contentful? We have included the following built-in templates:

```
blog
gallery
catalogue
```

You can use these with the `--template` option to create some demo data and start developing
against our APIs right away. Once you've gotten comfortable, you can
[create your own templates](#json-templates) for quickly replicating testing & development spaces.

### Using from within other applications

Include `contentful_bootstrap` to your project's `Gemfile`

```ruby
gem "contentful_bootstrap"
```

Require `contentful_bootstrap`

```ruby
require 'contentful/bootstrap'
```

To Create a new Space

```ruby
Contentful::Bootstrap::CommandRunner.new.create_space("space_name")
```

Additionally, you can send an options hash with the following keys:

```ruby
options = {
  template: "blog", # Will use one of the predefined templates and create Content Types, Assets and Entries
  json_template: "/path/to/template.json", # Will use the JSON file specified as a Template
  locale: "es-AR", # Will create the space with the specified locale code as default locale, defaults to "en-US"
  mark_processed: false, # if true will mark all resources as 'bootstrapProcessed' and will be avoided for update_space calls (doesnt affect create_space)
  no_publish: false, # if true it won't publish your entries or assets
  trigger_oauth: true, # if true will trigger OAuth process
  quiet: false, # if true will not output to STDOUT
  no_input: false # if true all input operations won't be done, exceptions thrown with alternatives through configuration file in cases in which it cannot proceed
}
Contentful::Bootstrap::CommandRunner.new.create_space("space_name", options)
```

To Update an existing Space

```ruby
options = {
  json_template: "/path/to/template.json", # Will use the JSON file specified as a Template
  environment: "master", # Will update the specified environment, will NOT create the environment if it doesn't exist, defaults to "master"
  locale: "es-AR", # Will create the space with the specified locale code as default locale, defaults to "en-US"
  mark_processed: false, # if true will mark all resources as 'bootstrapProcessed and will be avoided on future update_space calls
  trigger_oauth: true, # if true will trigger OAuth process
  skip_content_types: false, # if true will avoid creating the content types
  no_publish: false, # if true it won't publish your entries or assets
  quiet: false, # if true will not output to STDOUT
  no_input: false # if true all input operations won't be done, exceptions thrown with alternatives through configuration file in cases in which it cannot proceed
}
Contentful::Bootstrap::CommandRunner.new.update_space("space_id", options)
```

To Create a new Delivery API Token

```ruby
Contentful::Bootstrap::CommandRunner.new.generate_token("space_id")
```

Additionally, you can send an options hash with the following keys:

```ruby
options = {
  name: "Some Nice Token Name", # Will Create the Delivery API Token with the specified name
  trigger_oauth: true, # if true will trigger OAuth process
  quiet: false, # if true will not output to STDOUT
  no_input: false # if true all input operations won't be done, exceptions thrown with alternatives through configuration file in cases in which it cannot proceed
}
Contentful::Bootstrap::CommandRunner.new.generate_token("space_id", options)
```

To Generate a JSON Template from an exising Space

```ruby
Contentful::Bootstrap::CommandRunner.new.generate_json(
  "space_id",
  access_token: "delivery_or_preview_api_access_token",
  environment: "master", # Will fetch content from the specified environment, defaults to "master"
  use_preview: false, # if true will fetch from the Preview API instead of Delivery API
  filename: nil, # path to file in which to store JSON
  content_types_only: false, # if true will not fetch Entries and Assets
  content_type_ids: [], # if any ID is specified, JSON will only include those content types and entries that have that content type
  quiet: false, # if true will not output to STDOUT - only when filename is provided
  no_input: false # if true all input operations won't be done, exceptions thrown with alternatives through configuration file in cases in which it cannot proceed
)
```

Additionally, you can send an options hash with the following keys:
**NOTE**: The `:access_token` key is required in the options hash

```ruby
options = {
  access_token: "access_token" # REQUIRED
  environment: "master", # Will fetch content from the specified environment, defaults to "master"
  use_preview: false, # if true will fetch from the Preview API instead of Delivery API
  filename: "template.json", # Will save the JSON to the specified file
  content_types_only: false, # if true will not fetch Entries and Assets
  content_type_ids: [], # if any ID is specified, JSON will only include those content types and entries that have that content type
  quiet: false, # if true will not output to STDOUT
  no_input: false # if true all input operations won't be done, exceptions thrown with alternatives through configuration file in cases in which it cannot proceed
}
Contentful::Bootstrap::CommandRunner.new.generate_json("space_id", options)
```

Optionally, `CommandRunner#new` will take a parameter for specifying a configuration path

### Configuration

Contentful Bootstrap will read by default from `~/.contentfulrc`, but you can provide your own
file by using the `--config CONFIG_PATH` parameter

If you don't have `~/.contentfulrc` created, you will be prompted if you want to create it

#### Configuration Format

The configuration file will be in `ini` format and looks like the following

```ini
[global]
CONTENTFUL_ORGANIZATION_ID = an_organization_id
CONTENTFUL_MANAGEMENT_ACCESS_TOKEN = a_management_access_token

[space_name]
SPACE_ID = some_space_id ; Space configurations are not required by this tool, but can be generated by it
CONTENTFUL_DELIVERY_ACCESS_TOKEN = a_delivery_acces_token
```

### JSON Templates

Using the `--json-template` option, you can create spaces with your own predefined content.
This can be useful for creating testing & development spaces or just starting new projects from
a common baseline. You can find a complete example [here](./examples/templates/catalogue.json)

Using the `--mark-processed` option alongside `--json-template` will mark all resources as `bootstrapProcessed`,
which will make it so `update_space` calls avoid already created resources. (A resource being either a Content Type, Entry or Asset).

## Workflow for backing up draft/updated content

In many cases, you want to have a dump of your whole space, including draft/updated content.
To achieve this, do the following:

1. Export the content:

```bash
# Export published content
contentful_bootstrap generate_json <SPACE_ID> <DELIVERY_TOKEN> -o bootstrap-published.json

# Export draft/updated content
contentful_bootstrap generate_json <SPACE_ID> <PREVIEW_TOKEN> -o bootstrap-preview.json --use-preview
```

> Notice that on the second command we're using the `--use-preview` flag to use the Preview API to fetch the content.

2. Create or update a space with the templates:

```bash
# Import published content
contentful_bootstrap update_space <SPACE_ID> -j bootstrap-published.json

# Import draft/updated content
contentful_bootstrap update_space <SPACE_ID> -j bootstrap-preview.json --no-publish
```

> Notice that on the second command we're using the `--no-publish` flag to avoid publishing content that was originally draft/updated.

With this simple two-step process, you ensure that your content is fully reproducible, even if it's in draft state.

## Contributing

Feel free to improve this tool by submitting a Pull Request. For more information,
please check [CONTRIBUTING.md](./CONTRIBUTING.md)
