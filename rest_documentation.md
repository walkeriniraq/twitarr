# Rest Documentation

This documentation is for the rest endpoints under /api/v2

## Parameter Type Definition

* boolean - (true, false, 1, 0, yes, no)
* datetime string - ISO 8601 date/time, or unix epoch in milliseconds
* ISO_8601_DATETIME - ISO 8601 date/time
* epoch - unix epoch in milliseconds
* id_string - a string for the id
* username_string - user's username.  All lowercase word characters of atleast 3, with the posibility of '-'s and '&'s

## Seamail information

### Seamail specific types

#### SeamailDetails

    JSON SeamailDetails {
    "seamail": Object {
        "id": "id_string",
        "users": Array [
          Object { "username": "username_string",
                 "display_name": "displayname_string"
          }, …],
        "subject": "string",
        "messages": Array [
            SeamailMessage {
            "author": "username_string",
            "author_display_name": "displayname_string",
            "text": "string",
            "timestamp": "ISO_8601_DATETIME"
            }, …
        ],
        "is_unread": boolean
    }
    }

#### SeamailMetaInfo

    JSON SeamailMetaInfo {
    "id": id_string,
    "users": ARRAY [ Object {
               "username": "username_string",
               "display_name": "displayname_string"
               },
               … ],
    "subject": "string",
    "messages": "\d+ message",
    "timestamp": "ISO_8601_DATETIME",
    "is_unread": boolean
    }

### GET /api/v2/seamail

Gets the User's seamail (Not the messages contained within, just the subject, etc)

#### Requires

* logged in.
    * Accepts: key query parameter

#### Query parameters

* unread=&lt;boolean&gt; - Optional (Default: false) - only show unread seamail if true
* after=&lt;datetime string&gt; - Optional (Default: all messages) - Only show seamail after this point in time.

#### Returns

    {
    "seamail_meta": [ SeamailMetaInfo{…}, … ],
    "last_checked": epoch
    }

### GET /api/v2/seamail/:id_string

Gets the messages contained within a seamail

#### Requires

* logged in.
    * Accepts: key query parameter

#### Query parameters

none

#### Returns

    JSON SeamailDetails{…}

### POST /api/v2/seamail

Creates a new Seamail, with a initial message

#### Requires

* logged in.
    * Accepts: key query parameter

#### Query parameters

none

#### JSON Request Body

    JSON Object {
      "users": [username_string, …],   # no need to add the author, as that is automatically included
      "subject": "string",
      "text": "string"  # The first post's of the seamail's textual content
    }

#### Returns

    JSON SeamailDetails{…}

### POST /api/v2/seamail/:id/new_message

Create a new message within a Seamail

#### Requires

* logged in.
    * Accepts: key query parameter

#### Query parameters

none

#### JSON Request Body

    JSON Object {
      "text": "string"
    }

#### Returns

    JSON SeamailMessage{…}

### PUT /api/v2/seamail/:id/recipients

modifies the recipients of a seamail

#### Requires

* logged in.
    * Accepts: key query parameter

#### Query parameters

none

#### JSON Request Body

    JSON Object {
      "users": ["username_string", …]
    }

#### Returns

    JSON SeamailMetaInfo{…}

### GET /api/v2/user/new_seamail

Get how many unread seamails the user has

    {
    "status": "ok",
    "email_count": 0
    }


## Stream information

Get/post information on the tweet stream

### Stream specific types

    JSON StreamPostMeta {
        "id": "id_string",
        "author": "username_string",
        "display_name": "displayname_string",
        "text": "marked up text",
        "timestamp": "ISO_8601_DATETIME",
        "likes": null|Integer,
        "mentions": ["username_string", …],
        "entities": [ … ],
        "hash_tags": [ "word_character_string", … ],
        "parent_chain": [ "stream_post_id_string", …]
    }

    JSON StreamPostDetails {
    "id": "id_string",
    "author": "username_string",
    "display_name": "displayname_string",
    "text": "marked up text",
    "timestamp": "ISO_8601_DATETIME",
    "likes": null|Integer,
    "mentions": [ "username_string", … ],
    "entities": [ … ],
    "hash_tags": [ "word_character_string", … ],
    "parent_chain": [ "stream_post_id_string", .. ],
    "children": [StreamPostMeta{… Minus the parent_chain}, …]
    }


### GET /api/v2/stream

Get the recent tweets in the stream

#### Requires

#### Query parameters

* start=epoch - Optional (Default: Now) - The start location for getting tweets
* older_posts - Optional (Default: off) - If this parameter exist, retrieve posts older than this, otherwise get newer ones
* limit=Integer - Optional (Default: 20) - How many to tweets to get
* author=username_stream - Optional (Default:No Filter) - Filter by username specified

#### Returns

    JSON Object { "stream_posts": Array[ StreamPostMeta {…}, … ],
                  "next_page": 1421197659001
                }



### GET /api/v2/stream/:id

Get details of a stream post (tweet)
This will include the children posts (replies) to this tweet sorted in timestamp order

#### Requires

#### Query parameters

* limit=Integer - Optional(Default: 20) - Number of children posts to return with this tweet
* start_loc=Integer - Optional(Default: 0) - Start offset to display children posts

#### Returns

    JSON StreamPostDetails {…}

### GET /api/v2/stream/m/:query

View a user's mention's stream

#### Requires

#### Query parameters

* page=Integer - Optional(Default: 0) - Number of posts to return
* limit=Integer - Optional(Default: 20) - Start offset to view
* after=epoch - Optional(Default: None) - Start time to query for (only showing mentions newer than this)

#### Returns

    JSON Object {"status": "ok", "posts": [StreamPostMeta {…}, …],
                 "next": "page number to start with"}



### GET /api/v2/stream/h/:query

View a hash tag tweet stream

#### Requires

#### Query parameters

* page=Integer - Optional(Default: 0) - Number of posts to return
* limit=Integer - Optional(Default: 20) - Start offset to view
* after=epoch - Optional(Default: None) - Start time to query for (only showing mentions newer than this)

#### Returns

    JSON Object {"status": "ok", "posts": [StreamPostMeta {…}, …],
                 "next": "page number to start with"}


### POST /api/v2/stream/:id/like

Like a post

#### Requires

* logged in.
    * Accepts: key query parameter

#### Returns

Current users who like the post

    {
    "status": "ok",
    "likes": [
    "username_string", ...
    ]
    }

### DELETE /api/v2/stream/:id/like

Unlike a post

#### Requires

* logged in.
    * Accepts: key query parameter

#### Returns

   Current users who like the post

       {
       "status": "ok",
       "likes": [
       "username_string", ...
       ]
       }

### GET /api/v2/stream/:id/like

Get the current likes of a post

#### Requires

#### Returns

   Current users who like the post

       {
       "status": "ok",
       "likes": [
       "username_string", ...
       ]
       }

### POST /api/v2/stream

Posts or reply to a post in the stream.

#### Requires

* logged in.
    * Accepts: key query parameter

#### Json Request Body

    JSON Object { "parent": "stream_post_id_string", "text": "Tweet content", "photo": "photo_id_string"}

* The parent is optional.  If Specified, it will make this post a reply to another StreamPost by the id_string passed in.
* The photo is optional.  If Specified, it will make this post link in the photo that has already been uploaded with the id_string passed in.
* Text is *NOT* optional.  This will be the text of the tweet to be posted.

The author will be the logged in user.  The timestamp will be "Now", defaults to no likes.  The post will have mentions and hashtags automatically extracted.


#### Returns

    JSON StreamPostDetails {…}

### PUT /api/v2/stream/:id

Allows the user to edit the text or photo for this post.  Nothing else is modifyable

#### Requires

* logged in.
    * Accepts: key query parameter

#### JSON Request Body

    JSON Object {"text": "string", "photo": "photo_id_string"}

Both text and photo are optional, however, at least one must be specified.  If one is not specified it will not be changed.

A user may only edit their posts, unless they are an admin.

#### Returns

    JSON StreamPostDetails {…}

### DELETE /api/v2/stream/:id

Allows the user to delete a post

#### Requires

* logged in.
    * Accepts: key query parameter

A user may only edit their posts, unless they are an admin.

#### Returns

No body.  200-OK

## Hashtag information

Get some metainformation about hashtags

### GET hashtag/ac/:query

Get auto completion list for hashtags.  Query string must be greater than 3, and not include the '#' symbol

#### Returns

    {
    "values": [ "word_character_string"]
    }


### GET /api/v2/search?text=:query

Perform a search against the database for results.  Will search for Stream and Forum Posts, usernames, and seamail

#### Query params

* limit - The amount of objects per type returned
* page - The starting offset for objects being displayed (per type) returned
*

#### Returns

    JSON Object {
        "status": "ok",
        "stream_posts": {
        "matches": [ StreamPostMeta ,… ],
        "count": Integer:Count of matches,
        "more": boolean:True if more results than display is found
        },
        "forum_posts": {
        "matches": [ ForumPostMeta ,… ],
        "count": Integer:Count of matches,
        "more": boolean:True if more results than display is found
        },
        "users": {
        "matches": [ UserMeta, … ],
        "count": Integer:Count of matches,
        "more": boolean:True if more results than display is found
        },
        "seamails": {
        "matches": [ SeamailMetaInfo, … ],
        "count": Integer:Count of matches,
        "more": boolean:True if more results than display is found
        },
        "query": {
        "text": "used text query" (this may be modified from what is passed in, if required)
        }
    }

## User information

### GET /api/v2/user/auth

Log in user, returning a 'key' that can be used in each /api/v2 request that requires authentication.  This can be used
instead of having a session cookie.

### GET /api/v2/user/logout

Removes any session data for the request.  This really has no effect if using the 'key' style.

### GET /api/v2/user/whoami

Returns the logged in user's information

### GET /api/v2/user/autocomplete/:username

Get auto completion list for usernames.  Username string must be greater than 3, and not include the '@' symbol

### GET /api/v2/user/view/:username

View the user information

### GET /api/v2/user/photo/:username

Get the user's profile picture

#### Query args
* full=true - Optional(Default: false) - Returns a larger version of the profile image

#### Returns
[ binary data that makes up the photo ]

### POST /api/v2/user/photo

Modify the user's profile photo

### DELETE /api/v2/user/photo

Reset the user's profile to the default identicon image

## Event Information

Get/post information on events.

### Stream specific types

    JSON EventMeta {
        "id": "id_string",
        "author": "username_string",
        "display_name": "displayname_string",
        "title": "title_string",
        "location": "location_string",
        "start_time": "ISO_8601_DATETIME",
        "end_time": "ISO_8601_DATETIME",
        "signups": ["username_string", …],
        "favorites": ["username_string", …],
        "description": "marked up text",
        "max_signups": null|Integer
    }

### GET /api/v2/event/

#### Requires

#### Query parameters

* sort_by=variable name - Optional (Default: start_time) - First variable query is sorted by
* order=asc|desc - Optional (Default: desc) - Second variable query is searched by, ascending or descending

#### Returns

    JSON Object { "total_count": 5,
                  "events": Array[ EventMeta {…}, … ],
                }


### POST /api/v2/event/

Posts an event.

#### Requires

* logged in.
    * Accepts: key query parameter

#### Json Request Body

    JSON Object {
      "title": "string",
      "start_time": "ISO_8601_DATETIME",
      "location": "string",
      "description": "string",
      "end_time": "ISO_8601_DATETIME",
      "max_signups": integer
    }
    

* Description, end_time and max_signups are all optional fields. 

#### Returns

    JSON EventMeta {…}


### GET /api/v2/event/:id

Get details of an event.

#### Requires

#### Query parameters

#### Returns

    JSON EventMeta {…}


### DELETE /api/v2/event/:id

Destroy an owned event.

#### Requires

* logged in.
    * Accepts: key query parameter

A user may only delete their events, unless they are an admin.

#### Returns

No body. 200-OK


### PUT /api/v2/event/:id

Allows the user to edit the description, location, start and end times and max signups. Title is not modifyable.

#### Requires

* logged in.
    * Accepts: key query parameter

A user may only edit their events, unless they are an admin.

#### Json Request Body

    JSON Object {
      "description": "string",
      "location": "string",
      "start_time": "ISO_8601_DATETIME",
      "end_time": "ISO_8601_DATETIME",
      "max_signups": integer
    }
    

#### Returns

    JSON EventMeta {…}


### POST /api/v2/event/:id/signup

Allows the user to signup to an event.

#### Requires

* logged in.
    * Accepts: key query parameter

#### Query parameters

#### Returns

    JSON EventMeta {…}

### DELETE /api/v2/event/:id/signup

Allows the user to remove their signup from an event.

#### Requires

* logged in.
    * Accepts: key query parameter

#### Query parameters

#### Returns

    JSON EventMeta {…}

### POST /api/v2/event/:id/favorite

Allows the user to favorite an event.

#### Requires

* logged in.
    * Accepts: key query parameter

#### Query parameters

#### Returns

    JSON EventMeta {…}

### DELETE /api/v2/event/:id/favorite

Allows the user to remove their favorite from an event.

#### Requires

* logged in.
    * Accepts: key query parameter

#### Query parameters

#### Returns

    JSON EventMeta {…}