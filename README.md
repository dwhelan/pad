# Pad

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pad'
```

And then execute:

  $ bundle

Or install it yourself as:

  $ gem install pad

## Usage

### Entities
You can create entities which have a built-in 'id' attribute which uniquely identifies the entity.

```ruby
require 'pad'

class Person
  include Pad.entity

  attribute :name
  attribute :age
end

dave = Person.new id: 21, name: "Dave", age: 32 # => #<Person:0x007feaf4a3c668 @id=21, @name="Dave", @age=32>
dave.id   # => 21
dave.name # => "Dave"
dave.age  # => 32

another_dave = Person.new id: 21
dave == another_dave # => true
```

### Custom Classes
You can create your own classes and use Pad attributes.

```ruby
require 'pad'

class Vehicle
  include Pad.model

  attribute :year
  attribute :manufacturer
  attribute :make
end

sienna = Vehicle.new year: 2006, manufacturer: 'Toyota', make: 'Sienna' # => #<Vehicle:0x007fcdacd2ff38 @year=2006, @manufacturer="Toyota", @make="Sienna">
sienna.year # => 2006
sienna.year = 2007
sienna  # => #<Vehicle:0x007fcdacd2ff38 @year=2007, @manufacturer="Toyota", @make="Sienna">
```

## Contributing

1. Fork it ( https://github.com/dwhelan/pad/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
