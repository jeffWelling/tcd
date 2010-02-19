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
autoload :DateTime, 'date'
autoload :OptionParser, 'optparse'
autoload :OpenStruct, 'ostruct'
autoload :YAML, 'yaml'

module TCD
  STAT_FILE_REGEX=/(\d){4}-(\d){1,2}-(\d){1,2}\/(\d){1,2}-(\d){1,2}-(\d){1,2}_(in|out|aggr)\.txt/
  autoload :Common, 'lib/tcd/Common'
  autoload :Profiles, 'lib/tcd/Profiles'
  autoload :IRB, 'lib/tcd/irb'
  autoload :Storage, 'lib/tcd/Storage'
  autoload :Version, 'lib/tcd/Version'
  autoload :CLI, 'lib/tcd/CLI'
  autoload :Command, 'lib/tcd/Command'
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
        stats=TCD::IRB.getAllProfileStats
        #log "Bandwidth used since last update (in bytes) => #{stats.inspect}"
        TCD::Storage.saveStats stats
        sleep 60
      end
    end
  end
end
