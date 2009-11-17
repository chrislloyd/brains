class Brains
  def self.version
    File.read(libdir('..','VERSION')).freeze
  end
end
