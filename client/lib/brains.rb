require 'brains/cli'
require 'brains/version'

class Brains

  def self.libdir(*paths)
    File.join(File.dirname(__FILE__), *paths)
  end

end
