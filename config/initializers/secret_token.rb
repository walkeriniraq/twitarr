# Put the code below into "secret_token.rb" and replace "some secret token" with the output from "rake secret"

Twitarr::Application.config.secret_key_base = APP_CONFIG["SECRET_TOKEN"]
