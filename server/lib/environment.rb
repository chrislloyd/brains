def env
  @env ||= StringInquirer.new(ENV['ENVIRONMENT'] || 'development')
end