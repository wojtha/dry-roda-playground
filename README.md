# Dry-System & Roda Stack

This is demo of web stack based on [dry-rb](http://dry-rb.org) and [roda](http://roda.jeremyevans.net/index.html) routing tree web toolkit. It is extraction and simplification of [dry-web](https://github.com/dry-rb/dry-web) stack and [Berg](https://github.com/icelab/berg) (the company website of the one of the main dry-rb contributors) which is build with dry-rb, rom-rb and Roda.

I was building this from scratch or better say by copying bits and pieces from there and there to learn how these pieces of stack are wired together, but you can actually use prepared [dry-web-roda](https://github.com/dry-rb/dry-web-roda) stack which is also able to generate skeleton app.

### How to run this

Before I'll show the stack, here is just little snippet to make it work if you want just to see it action and dove into the internals by yourself:

```
git clone git@github.com:wojtha/dry-roda-playground.git
cd dry-roda-playground
bundle install
shotgun
```

### Web layer

Web layer is responsible for Roda can be switched to whatever routing system. I've picked it for several reasons: 

1. Routing is **much faster** than in Sinatra.
2. Has **nice plugin system** with [dozens of built-in plugins](http://roda.jeremyevans.net/documentation.html), so the core is very lean and it allows you pick just the stuff you need, so there is no additional and unwanted processing in the middleware layer during request or response.
3. The **routing tree concept** seemed to me completely weird, so I want to try it out 🤓.

### Application or bussiness logic layer

Application layer includes entities, validation, business rules and processes. I've choose following dry-rb libraries:

1. [dry-system](http://dry-rb.org/gems/dry-system) is actually combination of [dry-container](http://dry-rb.org/gems/dry-container) and [dry-auto_inject](http://dry-rb.org/gems/dry-auto_inject). This allows you to create **IoC containers with autoloading (!) 🍻** and easily inject all dependecies defined in the container anywhere in the model or service layer.  
2. [dry-types](http://dry-rb.org/gems/dry-types/) and [dry-struct](http://dry-rb.org/gems/dry-struct/) are used to load the app configuration, but it can be used later anywhere in the app when some type checks and coercion is needed, this two-gems-combo is basically modern replacement of the famous [Virtus](https://github.com/solnic/virtus) gem (and mostly from the same author actually).
3. [dry-configurable](http://dry-rb.org/gems/dry-configurable/) is used internally by `dry-system` but we can use it anywhere in the stack to make any class configurable.

### Persistence layer

[Sequel](http://sequel.jeremyevans.net/) is used just in configuration to show how to bootstrap the DB or ORM properly but it is actually not used anywhere.

### Bundler require

Unlike inner app dependencies `Bundler.require` is now intentionally omitted so you have to require all external dependencies manually.

## Interesting bits

Here, there are some interesting pieces of code which demostrates how all the stack is wired together.

1. [Booting container and app](#booting)
2. [Injecting autoloaded dependencies](#injecting)
3. [Using container inside Roda app](#container)

###Booting container and app<a name="booting"></a>

**config.ru** - standard Rackup config file

```ruby
require_relative 'system/boot'
run Main::Application.freeze.app
```

**system/boot.rb** - main boot loader, first it initializes the container and then it loads the app;

```ruby
require_relative 'container'
Main::Container.finalize!
require_relative 'application'
```

**system/main/container.rb** - main container of the application; here we can register various settings and services; main feature in this example is `auto_register`, which registeres all the objects in given folders automatically, but objects has to follow the naming convention;

```ruby
require 'dry/system/container'

module Main
  class Container < Dry::System::Container
    setting :env, ENV.fetch('RACK_ENV', 'development').to_sym

    configure do |config|
      config.auto_register = %w(lib)
    end

    load_paths!('lib')
  end
end
```

**system/main/import.rb** - here we define injector mixing for given container, see `Operations::Foo` below for example usage; it uses `dry-auto_inject` gem under hood;

```ruby
require_relative 'container'

module Main
  Import = Container.injector
end
```

### Injecting autoloaded dependencies<a name="injecting"></a>

**lib/operations/foo.rb** - operation with automatically injected dependencies; injector defines constructor and sets the dependencies as instance variables via the the constructor

```ruby
require 'main/import'

module Operations
  class Foo
    include Main::Import['services.bar', 'services.baz']

    def call(params)
      "Foo #{bar.call} #{baz.call}: #{params}"
    end
  end
end
```

**lib/services/bar.rb** and **lib/services/baz.rb**

```ruby
module Services
  class Bar # or Baz
    def call
      "Bar" # or Baz
    end
  end
end
```

### Using container inside Roda app<a name="container"></a>

**lib/configurable_roda.rb** - mixing the `roda` and `dry-configurable` which allows us to set `Dry::System::Container` as class level property; so we can access the container from inside the `roda` app later;

```ruby
require 'roda'
require 'dry-configurable'

class ConfigurableRoda
  extend Dry::Configurable

  setting :container

  def self.resolve(name)
    config.container[name]
  end

  def self.[](name)
    resolve(name)
  end
end
```

**system/main/application.rb** - finally the actual Roda application!

```ruby
require_relative 'container'

module Main
  class Application < ConfigurableRoda
    configure do |config|
      config.container = Container # same as ::Main::Container
    end
    
    # With those two plugins, Hash and Array output is automatically encoded as JSON
    plugin :default_headers, 'Content-Type' => 'application/json'
    plugin :json

    route do |r|
      r.root do
        # From Roda you can return content like from standard ruby method.
        { message: 'ok!' }
      end

      r.get 'foo' do
        # Call the 'operations.foo' object which is autoloaded and registered
        # in the container. Temp variables are used for more clarity.
        operation = self.class['operations.foo']
        result = operation.call(request.params) 
        { foo: result }
      end
    end
  end
end
```

## Links

* [Introduction to Roda](https://twin.github.io/introduction-to-roda/) by Janko Marohnić, 19 Aug 2015
* [Put HTTP in its place with Roda](https://www.icelab.com.au/notes/put-http-in-its-place-with-roda/) (and the whole series below the article) by Tim Riley, 24 May 2016
