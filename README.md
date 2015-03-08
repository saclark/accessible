# Accessible
[![Build Status](https://travis-ci.org/saclark/accessible.svg)](https://travis-ci.org/saclark/accessible) [![Coverage Status](https://coveralls.io/repos/saclark/accessible/badge.svg)](https://coveralls.io/r/saclark/accessible)

A simple and flexible means of configuration for Ruby applications.

# Set up a configuration class
Create a class in your project, include the `Accessible` module, and `load` a data source. You may then also `merge` in any number of additional data sources.
```ruby
class MyConfig
  include Accessible

  load 'config/defaults.yml'
  merge 'config/environments/dev.yml'
end
```

> Note: The `load` method will clear out any previously loaded data and replace it with the new data, whereas `merge` will merge in new data with previously loaded data (i.e. matching keys will be overridden and new keys will be added).

Both `load` and `merge` can take any of the following as a data source:
- A filepath to a yaml file (i.e. `'config/default.yml'`)
- A symbol representing the name of a yaml file found in `config/` (i.e. `:default`)
- A raw hash of data (i.e. `{ :base_url => 'http://www.example.com' }`)

Both methods also accept an optional second parameter: the name of a specific key within the data source, whose data is the only data that should be loaded from the source. This is provided in case you prefer to maintain a single configuration file with default and environment specific data separated out under different keys.

# Access your configuration data
There are two ways to access your configuration data.

Let's imagine the following data is loaded:
```ruby
{
  :environments => {
    :dev => {
      :users => [
        { :name => 'user0' },
        { :name => 'user1' },
        { :name => 'user2' }
      ]
    }
  }
}
```

__Methods__

You can get and set data by calling methods on your data set that match the name of the keys. If you try to get or set a key does not exist, an error will be thrown.
```ruby
MyConfig.environments.dev.users[1].name # => 'user1'

MyConfig.environments.dev.users[1].name = 'new_user1'
MyConfig.environments.dev.users[1].name # => 'new_user1'

MyConfig.does_not_exist # => NoMethodError
MyConfig.does_not_exist = 'foo' # => NoMethodError
```

__Brackets__

You may also use the familiar `:[]` and `:[]=` methods, which behave the same as they do on any hash. `:[]` will return `nil` if the key does not exist, `:[]=` will create and set the key-value pair if the key does not exist. This makes `:[]` useful for providing default values.
```ruby
MyConfig[:environments][:dev][:users][1][:name] # => 'user1'

MyConfig[:environments][:dev][:users][1][:name] = 'new_user1'
MyConfig[:environments][:dev][:users][1][:name] # => 'new_user1'

MyConfig[:does_not_exist] || 'default' # => 'default'
MyConfig[:new_key] = 'foo' # => `:new_key => 'foo'` pair is created
```

---

Check out the unit tests for the nitty-gritty of how things should work.
