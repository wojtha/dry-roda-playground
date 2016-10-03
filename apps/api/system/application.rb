require 'roda'
require 'dry-configurable'
require_relative 'container'

module Api
  class Application < Roda
    extend Dry::Configurable

    setting :container

    configure do |config|
      config.container = Container
    end

    plugin :error_handler
    plugin :not_found
    plugin :default_headers, 'Content-Type' => 'application/json'
    plugin :json

    def self.resolve(name)
      config.container[name]
    end

    def self.[](name)
      resolve(name)
    end

    route do |r|
      r.root do
        { message: 'ok!' }
      end

      r.get 'config' do
        self.class['config'].to_h
      end

      r.get 'foo' do
        { foo: self.class['operations.foo'].() }
      end

      r.get 'fail' do
        fail
      end
    end

    not_found do
      { message: 'Not found!' }
    end

    error do |e|
      raise e
      # { error: e.class, message: e.message }
    end
  end
end
