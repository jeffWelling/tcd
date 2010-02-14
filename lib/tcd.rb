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

module TCD
  autoload :Common, 'lib/tcd/Common'
  autoload :Profiles, 'lib/tcd/Profiles'
  autoload :IRB, 'lib/tcd/irb'
  class << self
    def main
      loop do
        extend TCD::Common
        log "The thing is using this many bandwidths 0.0"
        sleep 3
      end
    end
  end
end
