require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'

cfg = Log4r::YamlConfigurator
cfg['RAILS_ROOT'] = RAILS_ROOT
cfg['RAILS_ENV'] = RAILS_ENV

cfg.load_yaml_file "#{RAILS_ROOT}/config/log4r.yml"
RAILS_DEFAULT_LOGGER = Log4r::Logger['default']
RAILS_DEFAULT_LOGGER.level = RAILS_ENV == 'development' ?  Log4r::DEBUG : Log4r::INFO
