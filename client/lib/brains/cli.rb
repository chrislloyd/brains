require 'fileutils'

class Brains

  def self.usage
    'usage: brains new|serve <brain>'
  end

  def self.make(path)
    path = File.join(Dir.pwd, path)
    abort "Path #{path} already exists." if File.exist?(path)

    Dir.mkdir(path)
    ['brain.rb', 'config.ru'].each do |f|
      FileUtils.cp(Brains.libdir('templates', f), File.join(path, f))
    end
  end

  def self.serve(path)
    path = File.expand_path(File.join(Dir.pwd, path))
    abort "#{path} is not a Brain." unless File.directory?(path)

    name = File.basename(path)

    require 'dnssd'
    require 'uuid'

    Dir.chdir(path) do
      puts id = [name, UUID.new.generate].join('-')
      # Send ID to server
      # Receive token
      # Set environment variables BRAIN_ID to id and BRAIN_TOKEN to token

      webserver = fork {exec 'rackup -p 4567'}

      ['SIGHUP', 'SIGINT', 'SIGQUIT', 'SIGABRT', 'SIGKILL', 'SIGTERM'].each do |signal|
        trap signal do
          Process.kill signal, webserver
          Process.waitall
          exit
        end
      end

      Process.waitpid(webserver)
    end
  end

# private

  def self.error(msg)
    abort msg
  end

end
