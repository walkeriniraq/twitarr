class HomeController < ApplicationController

  def index
  end

  def time
    render_json time: Time.now.strftime('%B %d, %l:%M %P %Z')
  end

end
