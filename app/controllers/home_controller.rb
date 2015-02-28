class HomeController < ApplicationController

  def index
    if read_only_mode? and !logged_in?
      redirect_to :login
    end
  end

end
