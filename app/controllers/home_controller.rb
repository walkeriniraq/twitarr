class HomeController < ApplicationController

  def index
  end

  def help
    @title = 'Twit-arr Help Page'
    render layout: 'static'
  end

end
