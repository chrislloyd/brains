require 'fileutils'

class Brains

  def self.make(name)
    projdir = File.join(Dir.pwd, name)
    error("Directory #{projdir} already exists.") if File.directory?(projdir)

    Dir.mkdir(projdir)

    FileUtils.cp(Brains.libdir('templates', 'brain.rb'), File.join(projdir, 'brain.rb'))

  end

  def self.error(msg)
    abort msg
  end

end
