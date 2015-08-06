require 'yaml'
require 'oauth'

module HTTPResponseDecodeContentOverride
  def initialize(h,c,m)
    super(h,c,m)
    @decode_content = true
  end
  def body
    res = super
    if self['content-length']
      self['content-length']= res.bytesize
    end
    res
  end
end
module Net
  class HTTPResponse
    prepend HTTPResponseDecodeContentOverride
  end
end

class MainWindowController < ApplicationController
  set_view(:login_window)
  set_title('Golden Big Pao')

  def initialize(*args)
    super
    token = YAML.load(Utility.get_resource('config/token.yml'))
    consumer = OAuth::Consumer.new(token['consumer']['key'], token['consumer']['secret'], :site => 'https://api.twitter.com')
    @request_token = consumer.get_request_token
    @authorize_url.text = @request_token.authorize_url
  end

  def authorize
    @access_token = @request_token.get_access_token(:oauth_verifier => @oauth_varifier.text)
    puts @access_token.token
    puts @access_token.secret

    puts "---------- Retrieving the timeline... ----------"

    response = @access_token.get('/1.1/statuses/home_timeline.json')
    timeline = JSON.load(response.body)
    timeline.each do |status|
      output = "#{status['user']['screen_name']}: #{status['text']}"

      puts output
    end
    @authorize_url.disable = true
    @oauth_varifier.disable = true
    @authorize.disable = true
    @pao.disable = false
  end

  def pao
    fc = FileChooser.new
    fc.set_title('Select log zip file to delete')
    file = fc.show_open_dialog(nil)
    if !file.nil?
      file_path = file.get_path.to_s
      @file_path.set_text(file_path)
      Zip::File.open(file_path) do |zip_file|
        zip_file.each do |entry|
          if entry.name.match(/^tweets\.csv$/)
            headers, *datas = CSV.parse(entry.get_input_stream.read)
            puts headers
            puts datas.size
          end
        end
      end
    end
  end
end

