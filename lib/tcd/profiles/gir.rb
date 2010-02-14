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
module TCD
  module Profiles
    module Gir
      class << self
        #Return true or false depending on if this profile should be applied.
        def useProfile?
          true
        end
        #
        def getStats
          extend TCD::Common
          {:eth0=>
          {:in=> getBytes(`/usr/bin/ssh -i #{File.expand_path("~/Documents/Projects/tcd")}/traffic_control_daemon_in.key gir 2>/dev/null`).to_i,      
          :out=> getBytes(`/usr/bin/ssh -i #{File.expand_path("~/Documents/Projects/tcd")}/traffic_control_daemon_out.key gir 2>/dev/null`).to_i}}
        end
        #The first day of the billing cycle.
        #My billing cycle rollover date is the eleventh.  If I've downloaded up to 100% of my bandwidth limit and have to stop, on the
        #11th I can start downloading again because the 11th of every month is the first day of my new billing cycle.  So, I'd enter 11.
        #You need to add a rolloverDay for each interface, and it must be in the for of a hash such as {:eth0=>11}.
        def rolloverDay
          {:eth0=>11}
        end
      end
    end
  end
end
