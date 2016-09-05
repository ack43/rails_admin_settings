# AckRailsAdminSettings

Fork of [RailsAdminSettings](https://github.com/rs-pro/rails_admin_settings)

App settings editable via RailsAdmin with support for ActiveRecord and Mongoid.

Supports images, files, html with or without sanitization, code with codemirror, etc.

## Features

- Lazy loading - loads settings only if they are needed during request
- Loads all settings at once and caches them for the duration of request
- Supports lots of setting kinds - yaml, html with ckeditor, phone numbers etc
- Each setting can be enabled and disabled within rails_admin, if it's disabled it returns default value for kind

## Installation

Add this line to your application's Gemfile:

    gem 'rails_admin_settings'

For activerecord, generage migration:

    rails g rails_admin_settings:migration

Then migrate:

    rake db:migrate

## Gemfile order matters

- Put it after rails_admin to get built-in support
- Put it after rails_admin_toggleable to get built-in support
- Put it after ckeditor/glebtv-ckeditor/rich to get built-in support
- Put it after russian_phone to get built-in support
- Put it after sanitized to get built-in support
- Put it after safe_yaml to get built-in support
- Put it after validates_email_format_of to get built-in support
- Put it after geocoder to get built-in support
- Put it after carrierwave / paperclip to get built-in support
- Put it after addressable to get built-in support

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails_admin_settings

## Basic Usage (like RailsSettings)

    Settings.admin_email = 'test@example.com'
    Settings.admin_email


## Advanced Usage

    Settings.content_block_1(kind: 'html', default: 'test')
    Settings.data(kind: 'yaml')
    Settings.data = [1, 2, 3]

    Settings.enabled?(:phone, kind: 'phone', default: '906 111-11-11') # also creates setting if it doesn't exist
    Settings.phone.area
    Settings.phone.subscriber

See more here: https://github.com/rs-pro/rails_admin_settings/blob/master/spec/advanced_usage_spec.rb

## Namespacing

Settings can have namespaces (useful for locale, etc)

    Settings.ns('test').s1 = 123
    Settings.ns('test').s1
    > "123"
    Settings.ns('main').s1
    > ""
    Settings.s1
    > ""
    Settings.ns_default = 'test'
    Settings.s1
    > "123"
    Settings.ns_default = 'main'
    Settings.ns_fallback = 'test'
    Settings.s1
    > "123"


## Cache control

  Settings.content_block_1(kind: 'html', default: 'test', cache_keys: ["block_name1", "block_name2", :other_block])
  Settings.content_block_1(kind: 'html', default: 'test', cache_keys: "block_name1 block_name2 other_block")

And Rails cache for this keys will be delete after each saving ('clear_cache' method). Also you can edit it in rails_admin panel.

## Value types

Supported types:

    string (input)
    text (textarea)
    boolean (checkbox)
    color (uses built-in RailsAdmin color picker)
    html (supports Rich, glebtv-ckeditor, ckeditor, but does not require any of them)
    sanitized (requires sanitize -- sanitizes HTML before saving to DB [Warning: uses RELAXED config!])
    integer (stored as string)
    yaml (requires safe_yaml)
    phone (requires russian_phone)
    email (requires validates_email_format_of)
    address (requires geocoder)
    file (requires paperclip or carrierwave)
    url (requires addressable)
    domain (requires addressable)
    js (requires codemirror)
    css (requires codemirror)


Strings and html support following replacement patterns:

    {{year}} -> current year
    {{year|2013}} -> 2013 in 2013, 2013-2014 in 2014, etc

## Usage with Rails Admin

Rails admin management for settings is supported out of the box

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
