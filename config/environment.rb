# Load the Rails application.
require File.expand_path('../application', __FILE__)
APP_CONFIG = YAML.load_file("config/application.yml")
# Initialize the Rails application.
Twitarr::Application.initialize!
