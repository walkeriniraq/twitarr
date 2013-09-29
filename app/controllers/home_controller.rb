class HomeController < ApplicationController
  skip_around_action :redis_context_filter, only: [:index]

  def index
  end
end
