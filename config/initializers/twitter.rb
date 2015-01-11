module Twitter::Autolink
  # this generates a warning, but I much prefer that to setting these EVERYWHERE
  DEFAULT_OPTIONS = {
        list_class: DEFAULT_LIST_CLASS,
        username_class: DEFAULT_USERNAME_CLASS,
        hashtag_class: DEFAULT_HASHTAG_CLASS,
        cashtag_class: DEFAULT_CASHTAG_CLASS,

        username_url_base: '#/user/',
        hashtag_url_base: '#/tag/',
        cashtag_url_base: '#/tag/',
        suppress_lists: true,
        suppress_no_follow: true,
        username_include_symbol: true,

        invisible_tag_attrs: DEFAULT_INVISIBLE_TAG_ATTRS
      }.freeze
end