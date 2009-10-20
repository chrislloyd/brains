require 'fancypath'
require 'json'
require 'core_ext'

module Brains
  def self.lib_path
    @lib_path ||= Fancypath(__FILE__).expand_path.dirname/(self.name.downcase)
  end

  load lib_path/'states.rb'
  load lib_path/'actor.rb'
  load lib_path/'zombie.rb'
  load lib_path/'human.rb'
end
