require 'logger'
# borrowed from https://github.com/thisismydesign/easy_logging
module Logging

  @log_destination = nil
  @loggers = {}

  def logger
    @logger ||= Logging.logger_for(self.class.name)
  end

  def self.log_destination= dest
    @log_destination = dest
  end

private

  # Executed when the module is included. See: https://stackoverflow.com/a/5160822/2771889
  def self.included(base)
    # Class level logger method for includer class (base)
    def base.logger
      @logger ||= Logging.logger_for(self)
    end
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.logger_for(classname)
    @loggers[classname] ||= configure_logger_for(classname)
  end

  def self.configure_logger_for(classname)
    logger = Logger.new(log_destination)
    logger.progname = classname
    logger
  end

  def self.log_destination
    @log_destination or STDOUT
  end

end