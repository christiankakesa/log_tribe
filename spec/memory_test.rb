require 'memory_profiler'

require_relative '../lib/log_tribe'

$stdout.sync = true
$stderr.sync = true

LogTribe::Loggers.new [::Logger.new(STDOUT), ::Logger.new(STDERR)]

MemoryProfiler.report(trace: [LogTribe::Loggers]) do
  1_000.times do |iter|
    LogTribe::Loggers.new([::Logger.new(STDOUT), ::Logger.new(STDERR)]).tap do |log|
      log.debug   "[ITER-DEBUG  ]: #{iter}"
      log.info    "[ITER-INFO   ]: #{iter}"
      log.warn    "[ITER-WARN   ]: #{iter}"
      log.error   "[ITER-ERROR  ]: #{iter}"
      log.fatal   "[ITER-FATAL  ]: #{iter}"
      log.unknown "[ITER-UNKNOWN]: #{iter}"
    end
  end
end.pretty_print
