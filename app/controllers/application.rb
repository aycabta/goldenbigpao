class ApplicationController
  include JRubyFX::Controller
  def self.set_view(name)
    if JRubyFX::Application.in_jar?
      appdir = ENV['GEM_HOME'].split('/')[-2]
      fxml("#{appdir}/app/views/#{name}.fxml")
    else
      fxml("views/#{name}.fxml")
    end
  end

  def initialize *args
  end

  def self.set_title title
    @title = title
  end

  def self.title
    @title ||= 'No Title'
  end

  def move klass, *args
    controller = @stage.fxml(klass, initialize: args)
    @stage.controller = controller
    @stage.title = klass.title
    @stage.show
  end
end
