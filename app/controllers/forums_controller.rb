class ForumsController < ApplicationController

  def index
    render_json forum_topics: [{
                                   'id' => 1,
                                   'subject' => 'subject a',
                                   'posts' => 3
                               }, {
                                   'id' => 2,
                                   'subject' => 'subject b',
                                   'posts' => 5
                               }]
  end

end