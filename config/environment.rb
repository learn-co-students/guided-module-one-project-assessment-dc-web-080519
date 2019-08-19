require 'bundler'
Bundler.require

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
require_all 'lib'

# comment out the below to turn on SQL logging
ActiveRecord::Base.logger = nil

