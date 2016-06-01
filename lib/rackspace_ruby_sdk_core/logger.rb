require 'logger'

class Peace::Logger

  def self.logger
    logger = Logger.new(STDOUT)

    if ENV['DEBUG_RAX'] == 'true'
      logger.level = Logger::DEBUG
    else
      logger.level = Logger::WARN
    end

    logger
  end

end
