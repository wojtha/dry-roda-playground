require 'dry-struct'
require 'types'
require 'yaml'

module Main
  class Config < Dry::Struct
    RequiredString = Types::Strict::String.constrained(min_size: 1)

    attribute :database_url, RequiredString
    attribute :basic_auth_user, Types::String
    attribute :basic_auth_password, Types::String

    def self.load(root, name, env)
      path = root.join('config').join("#{name}.yml")
      yaml = File.exist?(path) ? YAML.load_file(path) : {}

      config = schema.keys.each_with_object({}) do |key, memo|
        value = ENV.fetch(
          key.to_s.upcase,
          yaml.fetch(env.to_s, {})[key.to_s]
        )

        memo[key] = value
      end

      new(config)
    end
  end
end
