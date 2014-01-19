# Be sure to restart your server when you modify this file.

Twitarr::Application.config.session_store :cookie_store, {
    key: '_twitarr_session',
    expire_after: 7.days
}
