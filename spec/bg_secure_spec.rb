require File.dirname(__FILE__) + '/spec_helper'

describe BgSecure, ".url_for" do
  before do
    @path = "/path/file.ext"
    @base_url = "http://example.com#{@path}"
    @secret = 'secret'
    @time = 1234567890
  end

  it "raises an argument error if url is relative" do
    lambda { BgSecure.url_for('relative.jpg', 'secret') }.should raise_error(ArgumentError)
  end

  it "raises an argument error if :expires is weird" do
    lambda { BgSecure.url_for('relative.jpg', 'secret', :expires => []) }.should raise_error(ArgumentError)
  end

  it "creates a secure url with no expiration if :expires is not passed" do
    url = BgSecure.url_for(@base_url, @secret)
    url.should == "http://example.com/path/file.ext?e=0&h=74bea39e4aa13f08a6fc862fe29574fc"
  end

  it "creates a secure url with correct expiration (in UTC) if :expires is a Time" do
    time = 2.days.from_now
    url = BgSecure.url_for(@base_url, @secret, :expires => time)
    url.should =~ /\?e=#{time.utc.to_i}/
  end

  it "creates a secure url with correct expiration (in UTC) if :expires is a Date" do
    date = Date.today + 1
    url = BgSecure.url_for(@base_url, @secret, :expires => date)
    url.should =~ /\?e=#{date.to_time.utc.to_i}/
  end

  it "creates a secure url with correct expiration if :expires is an Integer" do
    url = BgSecure.url_for(@base_url, @secret, :expires => @time)
    url.should =~ /\?e=#{@time}/
  end

  it "adds the correct hash to the url" do
    url = BgSecure.url_for(@base_url, @secret, :expires => @time)
    url.should =~ /&h=#{ MD5.hexdigest(@secret + @path + "?e=#{@time}") }$/
  end

  it "responds with a url without the host if host is not passed" do
    url = BgSecure.url_for(@path, @secret, :expires => @time)
    url.should == "/path/file.ext?e=1234567890&h=9213cd1017ed8f9c0652c1cccb219e6e"
  end

  it "generates the same hash with or without a host" do
    path = URI.parse(BgSecure.url_for(@path, @secret, :expires => @time))
    url = URI.parse(BgSecure.url_for(@base_url, @secret, :expires => @time))
    url.path.should == path.path
  end
  
  it "adds allowed countries string" do
    url = BgSecure.url_for(@base_url, @secret, :expires => @time, :allowed => 'US,CA')
    url.should == "http://example.com/path/file.ext?e=1234567890&a=US,CA&h=fcc6943a5969158c163f65f870273f4b"
  end

  it "adds allowed countries array" do
    url = BgSecure.url_for(@base_url, @secret, :expires => @time, :allowed => %w(US CA))
    url.should == "http://example.com/path/file.ext?e=1234567890&a=US,CA&h=fcc6943a5969158c163f65f870273f4b"
  end

  it "adds disallowed countries string" do
    url = BgSecure.url_for(@base_url, @secret, :expires => @time, :disallowed => 'US,CA')
    url.should == "http://example.com/path/file.ext?e=1234567890&d=US,CA&h=8e35b41c89d91e141e610fff23e9e3b5"
  end

  it "adds disallowed countries array" do
    url = BgSecure.url_for(@base_url, @secret, :expires => @time, :disallowed => %w(US CA))
    url.should == "http://example.com/path/file.ext?e=1234567890&d=US,CA&h=8e35b41c89d91e141e610fff23e9e3b5"
  end

  it "adds unlock" do
    url = BgSecure.url_for(@base_url, @secret, :expires => @time, :unlock => true)
    url.should == "http://example.com/path/file.ext?e=1234567890&g=1&h=bfbf3b0758cb05981f70caedf89f75c5"
  end

  it "prefers :unlock over :allowed" do
    url = BgSecure.url_for(@base_url, @secret, :expires => @time, :unlock => true, :allowed => 'US')
    url.should == "http://example.com/path/file.ext?e=1234567890&g=1&h=bfbf3b0758cb05981f70caedf89f75c5"
  end

  it "prefers :allowed over :disallowed" do
    url = BgSecure.url_for(@base_url, @secret, :expires => @time, :allowed => 'US,CA', :disallowed => 'CD')
    url.should == "http://example.com/path/file.ext?e=1234567890&a=US,CA&h=fcc6943a5969158c163f65f870273f4b"
  end
end
