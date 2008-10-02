require 'md5'

module BgSecure
  def self.url_for(url, secret, options = {})
    uri = URI.parse(url)
    path = uri.path

    unless path =~ /^\/.+/
      raise ArgumentError, "Path [#{path}] is invalid for generating a BitGravity secure URL"
    end

    timeout = options[:expires] || 0
    timeout = timeout.to_time.utc if timeout.respond_to?(:to_time)

    unless timeout.respond_to?(:to_i)
      raise ArgumentError, "Invalid :expires option [#{timeout.inspect}] for BitGravity secure URL"
    end

    # We just glom onto the path here because the order matters and there's
    # only a couple options
    path << "?e=#{timeout.to_i}"
      
    if options[:unlock]
      path << '&g=1'
    elsif options[:allowed]
      path << "&a=#{country_options_to_s(options[:allowed])}"
    elsif options[:disallowed]
      path << "&d=#{country_options_to_s(options[:disallowed])}"
    end

    path << "&h=#{MD5.hexdigest(secret + path)}"

    begin
      # Merges the uri if there is a host in the url that was passed
      uri.merge(path).to_s
    rescue URI::BadURIError # "both URI are relative"
      # url in arguments was relative ("/path/file.ext") so just return our new relative path
      path
    end
  end

  protected
    def self.country_options_to_s(countries)
      case countries
      when String
        countries
      when Array
        countries.map { |country| country.to_s }.join(',')
      else
        raise ArgumentError, "Invalid :allowed/:disallowed option [#{options[:allowed]}] for BitGravit secure URL"
      end
    end
end
