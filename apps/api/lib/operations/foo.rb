require_relative '../../system/import'

module Operations
  class Foo
    include Api::Import[barr: 'services.bar', bazz: 'services.baz']

    def call
      "Fuuuuuu #{barr.call} #{bazz.call}"
    end
  end
end
