require 'ruby-progressbar'
require 'logger'

#==============================================================================
# Utils methods and classes
#==============================================================================
module Utils
  def self.convert_hash_with_symbols_as_key(h)
    Hash[h.map { |k, v| [k.to_sym, v] }]
  end

  # LogFormatter
  class LogFormater < ::Logger::Formatter
    def call(severity, time, progname, msg)
      prefix = "[#{time.iso8601}][#{severity}]"
      prefix += "[#{progname}]" if progname
      # msg2str is the internal helper that handles different msgs correctly
      "#{prefix} #{msg2str(msg)}\n"
    end
  end

  def self.create_logger(progname = nil)
    logger = Logger.new(STDOUT)
    logger.progname = progname if progname
    logger.formatter = Utils::LogFormater.new
    logger
  end

  # ProgressBar with options from application config
  class ProgressBar < ::ProgressBar
    class << self
      def create(options)
        super(default_config.merge(options))
      end

      def default_config
        Utils.convert_hash_with_symbols_as_key(
          Application.config['utils']['progress_bar']
        )
      end
    end
  end
end
