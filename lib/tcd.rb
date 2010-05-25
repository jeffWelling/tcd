=begin
  Copyright 2009, Jeff Welling

    This file is part of Traffic Control Daemon (aka, tcd).

    Traffic Control Daemon is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Traffic Control Daemon is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Traffic Control Daemon.  If not, see <http://www.gnu.org/licenses/>.
  
=end

current_dir=File.expand_path(File.dirname(__FILE__))
unless $LOAD_PATH.first == (current_dir)
  $LOAD_PATH.unshift(current_dir)
end
autoload :Syslog, 'syslog'
autoload :IfconfigWrapper, 'ruby-ifconfig/lib/ifconfig.rb'
autoload :FileUtils, 'fileutils'
require 'date'
autoload :OptionParser, 'optparse'
autoload :OpenStruct, 'ostruct'
autoload :YAML, 'yaml'
autoload :SystemTimer, 'system_timer'

module TCD
  STAT_FILE_REGEX=/(\d){4}-(\d){1,2}-(\d){1,2}\/(\d){1,2}-(\d){1,2}-(\d){1,2}_(in|out|aggr)\.txt/
  MODULE_NAME_REGEX=/[^(::)]+$/
  libdir = 'lib/tcd/'
  Dir.glob(libdir + "*.rb").each {|lib| libname = File.basename lib, '.rb' ; libfile = libdir + libname ; lib = lib.to_sym ; autoload libname, libfile }
  class << self
    def main
      extend TCD::Common
      log "Traffic control daemon starting!"
      loop do
        Signal.trap("USR1") do
          log "Traffic control daemon still running!"
        end
        Signal.trap("TERM") do
          log "Traffic control daemon terminating!"
          exit
        end
        begin
          stats=TCD::IRB.getAllProfileStats
        rescue Exception => e
          log "#{e.to_s}"
          log "There was an error when getAllProfileStats was called..?"
        end
        
        begin
          x=TCD::IRB.aggregateAll
#          log x.to_s
        rescue Exception => e
          log "#{e.to_s}"
          log "There was an error when aggregateAll was called!"
        end
        sleep 60
        begin
          x=TCD::IRB.runTriggers
#          log x.to_s
        rescue Exception => e
          log "#{e.to_s}"
          log "runTriggers threw an error?"
        end
        
      end
    end
  end
end
