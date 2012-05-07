require 'log4r'
require 'log4r/outputter/datefileoutputter'
require 'log4r/formatter/patternformatter'
module Loggable
  def self.included base
    base.extend Loggable
  end

  def logger
    name = self.class == Class ? self.to_s : self.class.to_s
    begin
      Logger.get name
    rescue NameError
      logger = Log4r::Logger.new("default::#{name}")
      outputter = begin
        Log4r::DateFileOutputter.get name
      rescue NameError
        o = Log4r::DateFileOutputter.new name, :filename => "%s.log" % name, :dirname => 'log'
        o.formatter = Log4r::PatternFormatter.new :pattern => '%d %l [%C - %x]: %m'
      end
      logger.add name
      logger
    end
  end
end
