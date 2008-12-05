require 'md5'
require 'uri'

module BgSecure
  @@secret = nil
  # Call init with your secret key in config/initializer/bitgravity.rb
  def self.init(secret)
    @@secret = secret 
  end

  # Create secure urls for Bit Gravity by passing the url, your Bit Gravity
  # shared secret key, and an optional options hash.
  #
  # * url - Either a full url (http://example.com/path/file.ext) or a path
  # (/path/file.ext) to the secure asset. The response will be returned the
  # same as it was sent (with or without the host). A document relative
  # path will cause an ArgumentError. A kind_of URI::HTTP may also be
  # passed.
  # * secret - Your shared secret key from BitGravity.
  # * options - An optional hash of options (explained below).
  #
  # Valid options:
  #
  # * :expires - An object responding to :to_time, or and integer for seconds
  # since UTC Epoch. If this option is not passed, evaluates to false, or if 0
  # is passed, the url will not expire.
  # * :unlock - If set to true, will override any country based blocking. This
  # option takes precedence over :allowed and :disallowed so please pass only
  # one of these options.
  # * :allowed - Either an array of countries ['US', 'CA'] or a string "US,CA"
  # used to indicate allowed countries. This option will override :disallowed
  # and be overridden by :unlock so please pass only one of these options.
  # * :disallowed - Either an array of countries ['US', 'CA'] or a string
  # "US,CA" used to indicate disallowed countries. This option will be
  # overridden by :unlock or :allowed so please pass only one of these options.
  #
  def self.url_for(url, options = {})
    url = URI.parse(url) unless url.is_a? URI::HTTP
    path = url.path

    unless path =~ /^\/.+/
      raise ArgumentError, "Path [#{path}] is invalid for generating a BitGravity secure URL"
    end

    # We just glom onto the path here because the order matters and there's
    # only a couple options to add.
    path << "?e=#{timeout(options[:expires])}"
      
    if options[:unlock]
      path << '&g=1'
    elsif options[:allowed]
      path << "&a=#{country_options(options[:allowed])}"
    elsif options[:disallowed]
      path << "&d=#{country_options(options[:disallowed])}"
    end

    path << "&h=#{MD5.hexdigest(@@secret + path)}"

    begin
      # Merges the url if there is a host in the url that was passed
      url.merge(path).to_s
    rescue URI::BadURIError # "both URI are relative"
      # url in arguments was relative ("/path/file.ext") so just return our new relative path
      path
    end
  end

  protected
    def self.timeout(expires)
      timeout = expires || 0
      timeout = timeout.to_time.utc if timeout.respond_to?(:to_time)

      unless timeout.respond_to?(:to_i)
        raise ArgumentError, "Invalid :expires option [#{timeout.inspect}] for BitGravity secure URL"
      end

      timeout.to_i.to_s
    end

    def self.country_options(countries)
      case countries
      when String
        countries.gsub(/ /,'').upcase
      when Array
        countries.map { |country| country.to_s.upcase }.join(',')
      else
        raise ArgumentError, "Invalid :allowed/:disallowed option [#{options[:allowed]}] for BitGravit secure URL"
      end
    end
end
