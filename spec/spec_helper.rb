require 'rspec'

# Hard code the DATABASE environment variable so that it only
# connects to the test database when running rspec. Take a look
# inside app_config.rb to see how this value is being used.
ENV['DATABASE'] = 'development'
require_relative '../app_config'
require_relative '../app/models/mall'
require_relative '../app/models/store'

# Connect to the database once before running any tests.
AppConfig.establish_connection

# Clean the database between each test run using the database cleaner
require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
