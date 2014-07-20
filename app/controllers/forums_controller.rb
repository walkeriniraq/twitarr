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

  def show
    render_json forum: {
        id: params[:id],
        subject: 'hi',
        posts: [
            {
                author: 'steve',
                text: 'some text',
                date: DateTime.now
            }, {
                author: 'dave',
                text: 'more text',
                date: DateTime.now
            }
        ]
    }
  end

end