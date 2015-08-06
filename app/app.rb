# encoding: utf-8

require 'java'
require 'jrubyfx'
require 'bundler'

require 'thread'
File.delete('output.txt') if File.exist?('output.txt')
$hoge = Mutex.new
def loglog(msg)
  $hoge.synchronize do
    open('output.txt', 'a') do |f|
      f.write "#{msg}\n"
    end
  end
end

def detect_environment
  JRubyFX::Application.in_jar? ? 'production' : 'development'
end

def require_gems
  ENV['RACK_ENV'] ||= detect_environment
  Bundler.require(:default, ENV['RACK_ENV'].to_sym) unless JRubyFX::Application.in_jar?
end

require_gems

require_relative 'utility'
require_relative 'controllers/application'
Dir['app/controllers/*.rb', 'app/models/*.rb'].each do |file|
  require File.expand_path(file)
end

def jar_filename
  $LOAD_PATH.map { |it|
    it.split('/')
  }.flatten.uniq.select { |it|
    it.match(/^(?!jruby-complete\.jar!)(?!jruby-stdlib-[0-9\.]+\.jar!).+\.jar!$/)
  }.first.tap { |it|
    break it.tr('!','') unless it.nil?
  }
end

fxml_root(File.dirname(__FILE__), jar_filename)

class Java::javafx::stage::Stage
  attr_accessor :controller
end

class App < JRubyFX::Application
  def start(stage)
    @stage = stage
    controller = @stage.fxml(MainWindowController)
    @stage.controller = controller
    @stage.title = MainWindowController.title
    @stage.show
  end

  def stop
    @stage.controller.on_exit if @stage.controller.respond_to? :on_exit
  end
end

App.launch

