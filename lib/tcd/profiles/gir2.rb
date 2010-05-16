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
    module Gir2
      class << self
        #Return true or false depending on if this profile should be applied.
        def useProfile?
          true
        end
        #
        #
        def getStats
          extend TCD::Common
          eth1_in=`/usr/bin/ssh -i #{File.expand_path("~/Documents/Projects/tcd")}/traffic_control_daemon_eth1_in.key root@gir 2>/dev/null`
          eth1_out=`/usr/bin/ssh -i #{File.expand_path("~/Documents/Projects/tcd")}/traffic_control_daemon_eth1_out.key root@gir 2>/dev/null`
          eth2_in=`/usr/bin/ssh -i #{File.expand_path("~/Documents/Projects/tcd")}/traffic_control_daemon_eth2_in.key root@gir 2>/dev/null`
          eth2_out=`/usr/bin/ssh -i #{File.expand_path("~/Documents/Projects/tcd")}/traffic_control_daemon_eth2_out.key root@gir 2>/dev/null`
          { :eth1=>{:in=> toBytes(eth1_in.split("\n")[2].split[1]) , :out=> toBytes(eth1_out.split("\n")[2].split[1])},   
           :eth2=>{:in=> toBytes(eth2_in.split("\n")[2].split[1]) , :out=> toBytes(eth2_out.split("\n")[2].split[1])} }

        end
        #The first day of the billing cycle.
        #My billing cycle rollover date is the eleventh.  If I've downloaded up to 100% of my bandwidth limit and have to stop, on the
        #11th I can start downloading again because the 11th of every month is the first day of my new billing cycle.  So, I'd enter 11.
        #You need to add a rolloverDay for each interface, and it must be in the for of a hash such as {:eth0=>11}.
        def rolloverDay
          {:eth0=>11}
        end
        #Must return a hash, one symbol-key per interface, pointing to the number of bytes an interface
        #takes to reach 100% capacity.
        def maxCapacity
          #60GB => Bytes == 64 424 509 440
          {:eth0=>64424509440}
        end
        def getBytes src_str
          src_str.split("\n")[1].split(' ')[2].strip
        end
        #returns an array of the rules required to collect statistics for an interface
        def makeIptablesRules interface
          ["iptables -N #{interface.upcase}_in",
           "iptables -N #{interface.upcase}_out",
           "iptables -I FORWARD -i #{interface} -j #{interface.upcase}_in",
           "iptables -I INPUT -i #{interface} -j #{interface.upcase}_in",
           "iptables -I #{interface.upcase}_in -i #{interface}",
           "iptables -I FORWARD -o #{interface} -j #{interface.upcase}_out",
           "iptables -I OUTPUT -o #{interface} -j #{interface.upcase}_out",
           "iptables -I #{interface.upcase}_out -o #{interface}"
          ]
        end
        def toBytes num
          case num
          when /g$/i
            puts "g"
            return toBytes( (num.chop.to_i * 1024).to_s+"M" )
          when /m$/i
            puts "m"
            return toBytes( (num.chop.to_i * 1024).to_s+"K" )
          when /k$/i
            puts "k"
            return toBytes( (num.chop.to_i * 1024).to_s )
          else
            return num
          end
        end
      end
    end
  end
end
