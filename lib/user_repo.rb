require 'import'

class UserRepo
  include Main::Import['persistence.db']
end
