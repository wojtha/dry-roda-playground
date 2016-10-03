module Api
  class Container < Dry::System::Container
    require root.join('system/container')
    import Main::Container

    configure do |config|
      config.root = Pathname(__dir__).join('..').realpath.freeze

      config.default_namespace = 'api'

      config.auto_register = %w[
        lib/operations
        lib/services
      ]
    end

    load_paths! "lib", "system"
  end
end
