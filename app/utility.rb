require 'java'
require 'oauth'
require 'json'

class Utility
  PRODUCT_NAME = 'goldenbigpao'

  def self.config_dir
    case RbConfig::CONFIG['host_os']
    when /darwin/i
      File.expand_path("~/Library/#{PRODUCT_NAME}")
    when /mswin|mingw|cygwin/i
      # http://windows.microsoft.com/en-us/windows-8/what-appdata-folder
      "#{ENV['APPDATA']}/#{PRODUCT_NAME}"
    when /linux/i
      File.expand_path("~/.#{PRODUCT_NAME}")
    end
  end

  def self.current_os
    case java.lang.System.get_property("os.name")
    when /Mac OS X/ then :osx
    when /Windows/  then :windows
    else                 :unknown
    end
  end

  def self.get_resource(path)
    body = nil
    if JRubyFX::Application.in_jar?
      body = java.lang.Object.new.java_class.resource_as_string("/#{PRODUCT_NAME}/#{path}")
    else
      open(path, 'r') do |f|
        body = f.read
      end
    end
    body
  end
end

