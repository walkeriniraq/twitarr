require 'RMagick'
require 'siphash'

# creates an Identicon using Image Magick
module Identicon
  DEFAULT_OPTIONS = {
      border_size: 35,
      square_size: 50,
      grid_size: 7,
      background_color: 'transparent',
      key: "1234567890abcdef"
  }

  # create an identicon image
  #
  # Example:
  #   >> Identicon.create('identicons are great!')
  #
  # @param title [string] the string value to be represented as an identicon
  # @param options [hash] additional options for the identicon
  #
  # @return [Magick::Image]
  def self.create(title, options = {})
    options = DEFAULT_OPTIONS.merge(options)

    raise 'title cannot be nil' if title == nil
    raise 'key is nil or less than 16 bytes' if options[:key] == nil || options[:key].length < 16
    raise 'grid_size must be between 4 and 9' if options[:grid_size] < 4 || options[:grid_size] > 9
    raise 'invalid border size' if options[:border_size] < 0
    raise 'invalid square size' if options[:square_size] < 0

    hash = SipHash.digest(options[:key], title)

    canvas = Magick::ImageList.new
    dimensions = (options[:border_size] * 2) + (options[:square_size] * options[:grid_size])
    canvas.new_image(dimensions, dimensions) {
      if options[:background_color] and options[:background_color] != 'transparent'
        self.background_color = options[:background_color]
      end
    }
    blocks = Magick::Draw.new


    # set the stroke color based off of the hash
    # set the foreground color by using the first three bytes of the hash value
    color = '#%02X%02X%02X' % [(hash & 0xff), ((hash >> 8) & 0xff), ((hash >> 16) & 0xff)]
    # puts "Using color #{color}"
    blocks.stroke color
    blocks.fill color
    # remove the first three bytes that were used for the foreground color
    hash >>= 24

    sqx = sqy = 0
    (options[:grid_size] * ((options[:grid_size] + 1) / 2)).times do
      if hash & 1 == 1
        x = options[:border_size] + (sqx * options[:square_size])
        y = options[:border_size] + (sqy * options[:square_size])

        # left hand side
        blocks.rectangle(x, y, x + options[:square_size], y + options[:square_size])

        # mirror right hand side
        x = options[:border_size] + ((options[:grid_size] - 1 - sqx) * options[:square_size])
        blocks.rectangle(x, y, x + options[:square_size], y + options[:square_size])
      end

      hash >>= 1
      sqy += 1
      if sqy == options[:grid_size]
        sqy = 0
        sqx += 1
      end
    end
    blocks.draw canvas
    canvas.cur_image
  end
end