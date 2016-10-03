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
