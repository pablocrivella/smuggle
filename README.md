# Smuggle

[![Gem](https://img.shields.io/gem/v/smuggle.svg?style=flat)](http://rubygems.org/gems/smuggle)
[![Depfu](https://badges.depfu.com/badges/6f2f73672eae4d603d6ae923164435e2/overview.svg)](https://depfu.com/github/pcriv/smuggle?project=Bundler)
[![Inline docs](http://inch-ci.org/github/pcriv/smuggle.svg?branch=master&style=shields)](http://inch-ci.org/github/pcriv/smuggle)
[![Maintainability](https://api.codeclimate.com/v1/badges/b7192c49c395b2ac9bac/maintainability)](https://codeclimate.com/github/pcriv/smuggle/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/b7192c49c395b2ac9bac/test_coverage)](https://codeclimate.com/github/pcriv/smuggle/test_coverage)

Is a gem to manage exports and imports with ease, separating the logic from the models, resulting in a much cleaner codebase. Easy to use, with familiar structure.

**Smuggle is not dependent on Rails**, you can use it on ActiveModel/ActiveRecord models, as well as plain ruby objects and hashes.

Links:

- [API Docs](https://www.rubydoc.info/gems/smuggle)
- [Contributing](https://github.com/pcriv/smuggle/blob/master/CONTRIBUTING.md)
- [Code of Conduct](https://github.com/pcriv/smuggle/blob/master/CODE_OF_CONDUCT.md)

## Requirements

1. [Ruby 3.0.0](https://www.ruby-lang.org)

## Installation

To install, run:

```sh
gem install smuggle
```

Or add the following to your Gemfile:

```sh
gem "smuggle"
```

## Usage

### Exporters

Given the following plain old ruby object:

```ruby
class User
  attr_accessor :name

  def initialize(name)
    @name = name
  end
end
```

An exporter can be defined by inheriting from [Smuggle::Exporter::Base](lib/smuggle/exporter/base.rb) and defining the attributes to export:

```ruby
class UserExporter < Smuggle::Exporter::Base
  attributes :name
end
```

Extra logic can be establish inside the exporter file, using the same name as the attribute:

```ruby
class UserExporter < Smuggle::Exporter::Base
  attributes :name

  def name
    super + " - exported"
  end
end
```

If there are no attributes defined in the exporter and you are using ActiveModel or ActiveRecord, all the attributes of the record will be included.
If it is a hash, then all values will be included.

To generate the csv data simply call:

```ruby
users = [User.new("Rick Sanchez"), User.new("Morty Smith")]
Smuggle::Services::Export.call(scope: users, exporter: UserExporter)
# => "Full name,Full name\nRick Sanchez,Rick Sanchez\nMorty Smith,Morty Smith\n"
```

Or if you are using ActiveRecord, the exporter class will be automatically resolved from the scope:

```ruby
Smuggle::Services::Export.call(scope: User.all)
```

To add labels for your attributes (to show in the header instead of the raw attribute keys) you can add **attribute_labels** to your exporter:

``` ruby
class UserExporter < Smuggle::Exporter::Base
  attributes :name
  attribute_labels name: "Full name"
end

users = [User.new("Rick Sanchez"), User.new("Morty Smith")]

Smuggle::Services::Export.call(scope: users, exporter: UserExporter)
# => "Full name\nRick Sanchez\nMorty Smith\n"
```

### Importers

Given the following plain old ruby object:

```ruby
class User
  attr_accessor :name

  def initialize(name)
    @name = name
  end
end
```

An importer can be defined by inheriting from [Smuggle::Importer::Base](lib/smuggle/importer/base.rb) and defining the attributes to export:

```ruby
class UserImporter < Smuggle::Importer::Base
  # If no attributes are defined, the importer will infer them from the model's .attribute_names
  # If any attributes are explicitly defined, all other entries in the CSV are ignored
  attributes :name

  # Computed attributes from the row data
  def name
    [row[:first_name], row[:last_name]].join(" ")
  end

  def persist
    # Create your instance here
    model.new(to_h)
    # The result is collected by the Import service

    # If you want to persist your data, you can do so here. This is an example using ActiveRecord
    # model.create(to_h)
  end
end
```

For example:

Given the following `users.csv` file:

```
"first_name","last_name"
"Rick","Sanchez"
"Morty","Smith"
```

Just run:

```ruby
Smuggle::Services::Import.call(model: User, filepath: "users.csv")
# => [#<User name: "Rick Sanchez">, #<User name: "Morty Smith">]
```

The importer class will be resolved from the model name, otherwise you could explicitely set the importer like this:

```ruby
Smuggle::Services::Import.call(model: User, filepath: "users.csv", importer: UserImporter)
```

### Generators

If you are using rails you can use the following generators:

```
$ rails g smuggle:install
create app/exporters/application_exporter.rb
create app/importers/application_importer.rb
```

To generate an exporter, you can run the following command:

```
$ rails g smuggle:exporter user
create app/exporters/user_exporter.rb
```

You can also include the attributes you wish to export by running:

```
$ rails g smuggle:exporter user email username created_at
create app/exporters/user_exporter.rb
```

And to generate an importer, just run:

```
$ rails g smuggle:importer user email username full_name
create app/importers/user_importer.rb
```

## Tests

To test, run:

```
bundle exec rspec spec/
```

## Versioning

Read [Semantic Versioning](https://semver.org) for details. Briefly, it means:

- Major (X.y.z) - Incremented for any backwards incompatible public API changes.
- Minor (x.Y.z) - Incremented for new, backwards compatible, public API enhancements/fixes.
- Patch (x.y.Z) - Incremented for small, backwards compatible, bug fixes.

## License

Original work copyright 2017-2019 [Inspire Innovation BV](https://inspire.nl).
Continued work copyright 2019 Pablo Crivella.

Read [LICENSE](LICENSE) for details.

The development of this gem has been sponsored by Inspire Innovation BV (Utrecht, The Netherlands).
