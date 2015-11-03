# Contentful Bootstrap

A small CLI tool for getting started with Contentful

## Contentful
[Contentful](http://www.contentful.com) is a content management platform for web applications,
mobile apps and connected devices. It allows you to create, edit &nbsp;manage content in the cloud
and publish it anywhere via powerful API. Contentful offers tools for managing editorial
teams and enabling cooperation between organizations.

## What does `contentful_bootstrap` do?
The aim of `contentful_bootstrap` is to have developers setting up their Contentful environment
in a single command

## How to Use

### Installation

```bash
$ gem install contentful_bootstrap
```

### First Usage

```bash
$ contentful_bootstrap init <space_name> [--template template_name]
```


Then you can create other spaces by doing:

```bash
$ contentful_bootstrap create_space <space_name> [--template template_name]
```


You can also generate new Delivery API Tokens by doing:

```bash
$ contentful_bootstrap generate_token <space_id> [--name token_name]
```

### Available templates

The available templates for your spaces are:

```
blog
gallery
catalogue
```

This will get you started with Contentful by setting up a Space with some Demo Data to get you
started as soon as possible with development using our API.

### Using from within other applications

Include `contentful_bootstrap` to your project's `Gemfile`

```ruby
gem "contentful_bootstrap"
```

Require `contentful_bootstrap`

```ruby
require 'contentful/bootstrap'
```

To do the complete `init` process

```ruby
Contentful::Bootstrap::Commands.new.init("space_name", "template_name") # Template Name is optional
```


To create a new Space or Token. *This operations require a CMA Token located in `File.join(Dir.pwd, '.contentful_token')`*

```ruby
# Create a new Space
Contentful::Bootstrap::Commands.new.create_space("space_name", "template_name") # Template Name is optional

# Create a new CDA Access Token
Contentful::Bootstrap::Commands.new.generate_token("space_id", "token_name") # Token Name is optional
```

## Contributing

Feel free to improve this tool by submitting a Pull Request. For more information,
please check [CONTRIBUTING.md](./CONTRIBUTING.md)
