# Accessible
[![Gem Version](https://badge.fury.io/rb/accessible.svg)](http://badge.fury.io/rb/accessible) [![Build Status](https://travis-ci.org/saclark/accessible.svg)](https://travis-ci.org/saclark/accessible) [![Coverage Status](https://coveralls.io/repos/saclark/accessible/badge.svg)](https://coveralls.io/r/saclark/accessible)

A simple and flexible means of setting up configuration for Ruby applications.

# Usage
```ruby
MyConfig = Accessible.create do |config|
  confg.load   'config/defaults.yml'
  config.merge 'config/environments.yml', ENV['APP_ENV']
  config.merge { :foo => 'bar' }
end

MyConfig.wake_me_up.before.you_go.go?
# => true
```

# Documentation

## Creating an "Accessible" class
Assign the result of calling Accessible's `create` method, passing it a block in which you may `load`/`merge` any number of data sources.
```ruby
MyConfig = Accessible.create do |config|
  confg.load 'config/defaults.yml'
  config.merge 'config/environments/dev.yml'
end
```

Alternatively, you can create a class, include the `Accessible` module, and `load`/`merge` your data.
```ruby
class MyConfig
  include Accessible

  load 'config/defaults.yml'
  merge 'config/environments/dev.yml'
end
```

## Methods
The following class methods are available on any class created with/including Accessible.

* [`Accessor methods`](#user-content-accessor-methods)
* [`#load`](#user-content-load)
* [`#merge`](#user-content-merge)
* [`#[]`](#user-content--)
* [`#[]=`](#user-content--1)
* [`#to_h`](#user-content-to_h)

### Accessor methods
When you load data into your class, getter and setter methods are defined on the class and recursively through the loaded data for each key. This way you can easily walk through your data:
```ruby
MyConfig.my_deeply.nested.data_is.accessible
```

The main difference between accessor methods and [`[]`](#user-content--) and [`[]=`](#user-content--1) is that the accessor methods raise an error if a matching key does not exist.

Examples:
```ruby
MyConfig = Accessible.create do |config|
  config.load({
    :characters => {
      :calvin => {
        :alter_egos => [
          { :name => 'Spaceman Spiff' },
          { :name => 'Tracer Bullet' }
        ]
      }
    }
  })
end

MyConfig.characters.calvin.alter_egos[0].name
# => 'Spaceman Spiff'
MyConfig.characters[:calvin].alter_egos[0].name
# => 'Spaceman Spiff'

MyConfig[:characters].calvin.alter_egos[1].name = 'Stupendous Man'
# => 'Stupendous Man'
MyConfig.characters.calvin
# => {
#   :alter_egos => [
#     { :name => 'Spaceman Spiff' },
#     { :name => 'Stupendous Man' }
#   ]
# }

MyConfig.does_not_exist
# => NoMethodError
MyConfig[:does_not_exist]
# => nil

MyConfig.does_not_exist = 'foo'
# => NoMethodError
MyConfig[:new_key] = 'a new value'
# => 'a new value'
MyConfig.new_key
# => 'a new value'
```

Be careful with this one though. It is best to treat its return value as read-only due to surprising results when used in combination with `[]=` ([read why](#user-content--1)).

### load
`load(data_source, key = nil) -> data`

Loads data into your class, wiping out any previously loaded data. It accepts a data source as well as an optional second parameter representing the name of a specific key within the data source from which data should be loaded.

A data source can be any of the following:

__Hash__  
Loads the given hash:
```ruby
MyConfig.load({ :names => ['Calvin', 'Hobbes'] })
```

__String__  
The given string should represent a file path to an existing yaml file to be loaded. An error will be throw if the file cannot be found:
```ruby
MyConfig.load('config/env_config.yml')
```

__Symbol__  
The given symbol should represent the name of a `.yml` file located in a `/config` directory (relative to the working directory of the running process):
```ruby
MyConfig.load(:env_config)
```

Therefore, the following are equivalent
```ruby
# These are the same
MyConfig.load(:env_config)
MyConfig.load('config/env_config.yml')
```

### merge
`merge(data_source, namespace = nil) -> data`

Equivalent to [`load`](#user-content-load) with the exception that the data source is _merged_ (i.e. entries with duplicate keys are overwritten) with previously loaded data.

### []
`[key] -> value`

Gets data from your class. Returns `nil` if the key does not exist, making this method useful for assigning default values in the absence of a key.
```ruby
MyConfig.load({ :calvin => 'Spaceman Spiff' })

MyConfig[:calvin]
# => 'Spaceman Spiff'

MyConfig[:susie]
# => nil

person = MyConfig[:susie] || 'Hobbes'
# => 'Hobbes'
```

### []=
`[key] = value -> value`

Sets data on your class.
```ruby
MyConfig.load({})

MyConfig[:calvin] = 'Spaceman Spiff'
MyConfig[:calvin]
# => 'Spaceman Spiff'

MyConfig[:calvin] = 'Stupendous Man'
MyConfig[:calvin]
# => 'Stupendous Man'
```

Note, however, __this is _not_ functionally equivalent to setting values on the result of calling `to_h` on your class or it's values.__ (e.g. `MyConfig.to_h[:foo] = 'bar'`).

The subtle difference here is that using `[]=` directly on the class ensures that the appropriate accessor methods are defined on the class, it's data, and the value being set. Thus, the following works:
```ruby
MyConfig.load({ :calvin => { :superhero => 'Spaceman Spiff' } })

MyConfig[:calvin] = { :superhero => 'Stupendous Man' }

MyConfig.calvin
# => { :superhero => 'Stupendous Man' }

MyConfig.calvin.superhero
# => 'Stupendous Man'

MyConfig.calvin[:detective] = 'Tracer Bullet'
MyConfig.calvin.detective
# => 'Tracer Bullet'

MyConfig[:susie] = 'Derkins'
MyConfig.susie
# => 'Derkins'
```

Contrast this with the following behavior:
```ruby
MyConfig.load({ :calvin => { :superhero => 'Spaceman Spiff' } })

MyConfig.to_h[:calvin] = { :superhero => 'Stupendous Man' }

# The following only works by coincidence because an accessor for :calvin
# was defined when the config data was initially loaded
MyConfig.calvin
# => { :superhero => 'Stupendous Man' }

MyConfig.calvin.superhero
# => NoMethodError: undefined method `superhero' for {:superhero=>"Stupendous Man"}:Hash

MyConfig.calvin.to_h[:detective] = 'Tracer Bullet'
MyConfig.calvin.detective
# => NoMethodError: undefined method `detective' for {:superhero=>"Stupendous Man", :detective=>"Tracer Bullet"}:Hash

MyConfig.to_h[:susie] = 'Derkins'
MyConfig.susie
# => NoMethodError: undefined method `susie' for MyConfig:Class
```

As you can see, being sure to only use `[]=` on your class and it's values _directly_ ensures the proper accessors are maintained. Setting values on the return value of `to_h` is a recipe for disaster.

### to_h
`to_h -> data`

Returns all data loaded to your class as a hash.
```ruby
MyConfig.load({ :names => ['Calvin', 'Hobbes'] })

MyConfig.to_h
# => { :names => ['Calvin', 'Hobbes'] }
```
