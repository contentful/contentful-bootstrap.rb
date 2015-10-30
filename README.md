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

## Contributing

Feel free to improve this tool by submitting a Pull Request. For more information,
please check [CONTRIBUTING.md](./CONTRIBUTING.md)
