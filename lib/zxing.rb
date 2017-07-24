require 'zxing/version'
require 'zxing/decoder'

module ZXing
  class UndecodableError < StandardError
    def message; "Image not decodable"; end
  end

  ##
  # Decodes barcodes from an image file
  #
  # +file+ should be the path to the image file to decode, as a string.
  #
  # Example:
  #
  #   path = "path/to/file.png"
  #   ZXing.decode(path) #=> "Encoded text"
  #
  # When the image cannot be decoded, +decode+ returns +nil+:
  #
  #   path = "./no_encoded_image.png"
  #   ZXing.decode(path) #=> nil
  #
  def self.decode(file, retry_once: false)
    handle_lost_connection(retry_once) { decoder.decode normalize(file) }
  end

  ##
  # Same as +decode+, but raises an exception when image cannot be decoded.
  #
  # +file+ should be the path to the image file to decode, as a string.
  #
  # Example:
  #
  #   path = "./no_encoded_image.png"
  #   ZXing.decode(path) #=> ZXing::UndecodableError
  #
  def self.decode!(file, retry_once: false)
    handle_lost_connection(retry_once) { decoder.decode! normalize(file) }
  end

  ##
  # Decodes barcodes from an image file, and returns an array of encoded
  # values.
  #
  # +file+ should be the path to the image file to decode, as a string.
  #
  # Example:
  #
  #   path = "path/to/file.png"
  #   ZXing.decode_all(path) #=> ["First encoded text","Second encoded text"]
  #
  # When the image cannot be decoded, +decode_all+ returns +nil+:
  #
  #   path = "./no_encoded_image.png"
  #   ZXing.decode_all(path) #=> nil
  #
  def self.decode_all(file, retry_once: false)
    handle_lost_connection(retry_once) { decoder.decode_all normalize(file) }
  end

  ##
  # Same as +decode_all+, but raises an exception when image cannot be decoded.
  #
  # +file+ should be the path to the image file to decode, as a string.
  #
  # Example:
  #
  #   path = "./no_encoded_image.png"
  #   ZXing.decode(path) #=> ZXing::UndecodableError
  #
  def self.decode_all!(file, retry_once: false)
    handle_lost_connection(retry_once) { decoder.decode_all! normalize(file) }
  end

  def self.qrcode_decode(file, retry_once: false)
    handle_lost_connection(retry_once) { decoder.qrcode_decode normalize(file) }
  end

  def self.decoder
    @decoder ||= Client.new
  end

  def self.normalize(file)
    file.respond_to?(:path) ? file.path : file
  end

  def self.handle_lost_connection(retry_once)
    decoder # ensure the connection is opened (so that the port check works)

    if retry_once && !ZXing::Client.responsive?(ZXing::Client.port)
      @decoder = Client.new
    end

    yield
  end
end
