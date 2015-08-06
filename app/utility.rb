require 'java'
require 'oauth'
require 'json'

class Utility
  PRODUCT_NAME = 'goldenBigPao'

  def self.config_dir
    camel_product_name = PRODUCT_NAME.gsub(/^./, &:upcase)
    case RbConfig::CONFIG['host_os']
    when /darwin/i
      File.expand_path("~/Library/#{camel_product_name}")
    when /mswin|mingw|cygwin/i
      # http://windows.microsoft.com/en-us/windows-8/what-appdata-folder
      "#{ENV['APPDATA']}/#{camel_product_name}"
    when /linux/i
      File.expand_path("~/.#{camel_product_name}")
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

