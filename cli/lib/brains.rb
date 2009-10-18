require 'rubygems'
require 'yaml'
require 'json'

gem 'rest-client'
require 'rest_client'

def returning(value)
  yield(value)
  value
end


module Brains
  class User

    SERVER = 'http://game.local'
    TEMPLATE = File.expand_path(File.dirname(__FILE__)) + '/../templ/brain.rb'

    attr_accessor :key, :brains, :server

    def initialize
      self.brains = []
    end

    def self.from_disk_or_new
      user_file? ? from_disk : new
    end

    def self.from_disk
      yaml = YAML.load_file(user_file)
      returning(new) do |u|
        u.key = yaml['key']
        u.server = yaml['server']
        u.brains = yaml['brains']
      end
    end


    def self.user_file?
      File.exist?(user_file)
    end

    def self.user_file
      File.expand_path(fish? ? '~/.config/brains' : '~/.brains')
    end

    def self.fish?
      File.directory?(File.expand_path('~/.config'))
    end

    def request_new_key
      self.key = RestClient.get(server+'/keys/new').to_s
    end

    def server
      @server || SERVER
    end

    def brain_template
      File.read(TEMPLATE)
    end

    def add_brain(path)
      brain = File.expand_path(path)
      unless brains.include?(brain)
        File.open(brain, 'w') do |f|
          f.write brain_template
        end
        brains << brain
        system "#{ENV['EDITOR']} #{brain}"
      end
    end

    def code
      brains.inject({}) do |codes, brain|
        codes[brain] = File.read(brain)
        codes
      end
    end

    def url
      server+'/'+key
    end

    def push
      puts 'Pushing...'
      RestClient.put(url, code.to_json)
    end

    def brain_mtimes
      brains.inject(''){|mtimes, f| mtimes + File.mtime(f).to_i.to_s }
    end

    def sync
      previous = brain_mtimes
      loop do
        push unless previous == brain_mtimes
        sleep 1
      end
    end

    def to_yaml
      {
        'key' => key,
        'server' => server,
        'brains' => brains
      }.to_yaml
    end

    def save
      File.open(self.class.user_file,'w') {|f| f.write to_yaml }
    end

  end
end
