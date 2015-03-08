This branch will become a whole new gem eventually, with a different name and everything.

I will be the first to admit that this is basically a re-implementation of [settingslogic](https://github.com/binarylogic/settingslogic). I did so because:

1. I wanted to make an even less opinionated version that lets you load your data however you please (with ease).
2. I wanted to take a whole different technical approach.
3. It seemed like a fun technical exercise :smile:

# 1. Set up a configuration class
Create a class in your project and include the `Accessible` module. Then, provide a "base" data source to be used as the default data set.

You may then also provide any number of additional data sources to be _merged in_ with the default data set (i.e. matching keys will be overridden, new keys will be added).
```ruby
class MyConfig
  include Configular

  base 'config/defaults.yml'
  merge! 'config/environments/dev.yml'
end
```

Both `base` and `merge!` can take any of the following as a data source:
- A filepath to a yaml file
- A symbol representing the name of a yaml file found in `config/`
- A raw hash of data

Both methods also accept an optional second parameter: the name of a specific key within the data source, whose data is the only data that should be loaded from the source. This is provided in case you prefer to maintain a single configuration file with default and environment specific data separated out under different keys.

# 2. Access your configuration data
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

MyConfig.doesnt_exist # => NoMethodError
MyConfig.doesnt_exist = 'foo' # => NoMethodError
```

__Brackets__

You may also use the familiar `:[]` and `:[]=` methods, which behave the same as they do on any hash. `:[]` will return `nil` if the key does not exist, `:[]=` will create and set the key-value pair if the key does not exist. This makes `:[]` is useful for providing default values.
```ruby
MyConfig[:environments][:dev][:users][1][:name] # => 'user1'

MyConfig[:environments][:dev][:users][1][:name] = 'new_user1'
MyConfig[:environments][:dev][:users][1][:name] # => 'new_user1'

MyConfig[:doesnt_exist] || 'default' # => 'default'
MyConfig[:new_key] = 'foo' # => `:new_key => 'foo'` pair is created
```

---

Feel free to check out the unit tests for the nitty-gritty of how things should work.
