# frozen_string_literal: true

require 'logger'

module LogTribe
  class Loggers < ::Logger
    attr_reader :loggers, :tag_name

    # Logging severity threshold (e.g. <tt>::Logger::INFO</tt>).
    attr_reader :level

    # See #level
    def level=(value)
      @level = value
      @loggers.each do |logger|
        next unless logger
        logger.level = value if logger.respond_to?(:level)
      end
    end

    # Program name to include in log messages.
    attr_reader :progname

    # See #progname
    def progname=(value)
      @progname = value
      @loggers.each do |logger|
        next unless logger
        logger.progname = value if logger.respond_to?(:progname)
      end
    end

    # Returns the date format being used.  See #datetime_format=
    attr_reader :datetime_format

    # Set date-time format.
    #
    # +datetime_format+:: A string suitable for passing to +strftime+.
    def datetime_format=(datetime_format)
      @datetime_format = datetime_format
      @loggers.each do |logger|
        next unless logger
        logger.datetime_format = datetime_format if logger.respond_to?(:datetime_format)
      end
    end

    # Logging formatter, as a +Proc+ that will take four arguments and
    # return the formatted message. The arguments are:
    #
    # +severity+:: The Severity of the log message.
    # +time+:: A Time instance representing when the message was logged.
    # +progname+:: The #progname configured, or passed to the logger method.
    # +msg+:: The _Object_ the user passed to the log message; not necessarily a
    #         String.
    #
    # The block should return an Object that can be written to the logging
    # device via +write+.  The default formatter is used when no formatter is
    # set.
    attr_reader :formatter

    # See #formatter
    def formatter=(callable)
      @formatter = callable
      @loggers.each do |logger|
        next unless logger
        logger.formatter = callable if logger.respond_to?(:formatter)
      end
    end

    # See ::Logger#Formatter
    attr_reader :default_formatter

    # :call-seq:
    #   LogTribe::Loggers.new(log_or_logs_array, options)
    #
    # Create a multi log objects manager in order to send message through multiple destination loggers.
    #
    # === Attributes
    #
    # * +log_or_logs_array+ - A simple log object or an array of logger objects.
    # * +options+ - Options used in logger objects which makes sense.
    #
    # === Options
    #
    # * +:tag_name+ - Name of the tag for logger like FluentLogger (Fluentd).
    #
    # === Examples
    #
    # Build log's tribe:
    #
    #   LogTribe::Loggers.new([Logger.new(STDOUT), Fluent::Logger::FluentLogger.new(nil, host: 'srv', port: 10_010)], { tag_name: 'app_name.app_type' })
    #   LogTribe::Loggers.new(Logger.new(STDOUT))
    #   LogTribe::Loggers.new(Fluent::Logger::FluentLogger.new(nil, host: 'srv', port: 10_010), { tag_name: 'app_name.app_type' })
    #   LogTribe::Loggers.new(Fluent::Logger::FluentLogger.new(nil, host: 'srv', port: 10_010))
    #
    def initialize(log_or_logs_array, options = {})
      @loggers = Array(log_or_logs_array)
      @tag_name = options.delete(:tag_name)
      @level = INFO
      @default_formatter = Formatter.new
    end

    #
    # :call-seq:
    #   Logger#add(severity, message = nil, progname = nil) { ... }
    #
    # === Args
    #
    # +severity+::
    #   Severity.  Constants are defined in Logger namespace: +DEBUG+, +INFO+,
    #   +WARN+, +ERROR+, +FATAL+, or +UNKNOWN+.
    # +message+::
    #   The log message.  A String or Exception.
    # +progname+::
    #   Program name string.  Can be omitted.  Treated as a message if no
    #   +message+ and +block+ are given.
    # +block+::
    #   Can be omitted.  Called to get a message string if +message+ is nil.
    #
    # === Return
    #
    # When the given severity is not high enough (for this particular logger),
    # log no message, and return +true+.
    #
    # === Description
    #
    # Log a message if the given severity is high enough.  This is the generic
    # logging method.  Users will be more inclined to use #debug, #info, #warn,
    # #error, and #fatal.
    #
    # <b>Message format</b>: +message+ can be any object, but it has to be
    # converted to a String in order to log it.  Generally, +inspect+ is used
    # if the given object is not a String.
    # A special case is an +Exception+ object, which will be printed in detail,
    # including message, class, and backtrace.  See #msg2str for the
    # implementation if required.
    #
    # === Bugs
    #
    # * Logfile is not locked.
    # * Append open does not need to lock file.
    # * If the OS supports multi I/O, records possibly may be mixed.
    #
    def add(severity, message = nil, progname = nil, &block)
      @loggers.each do |logger|
        next unless logger
        if logger.respond_to?(:add)
          logger.add(severity, message, progname, &block)
        elsif defined?(::Fluent::Logger) && logger.respond_to?(:post)
          # FluentLogger
          logger.post(@tag_name || 'none',
                      message: format_message(format_severity(severity), Time.now, progname, message)
                     )
        end
      end
    end
    # alias_method :log, :add

    #
    # Dump given message to the log device without any formatting.  If no log
    # device exists, return +nil+.
    #
    def <<(msg)
      @loggers.each do |logger|
        next unless logger
        if logger.respond_to?(:<<)
          logger << msg
        elsif defined?(::Fluent::Logger) && logger.respond_to?(:post)
          # FluentLogger
          logger.post(@tag_name || 'none', message: msg)
        end
      end
    end

    #
    # Close the logging devices.
    #
    def close
      @loggers.each do |logger|
        next unless logger
        log_device = logger.instance_variable_get('@logdev')
        next unless log_device
        log_device.flush if log_device.respond_to?(:flush)
        logger.close if log_device.respond_to?(:stat)
      end
    end
  end
end
