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
require 'timeout'

module TCD
  module Profiles
    module Gir2
      class << self
        #Return true or false depending on if this profile should be applied.
        def useProfile?
          true
        end
        #The getStats() method must return an array of interfaces and their usage to comply with the API.
        #
        #For me, I do traffic collection on my gateway machine and analysis on another.  And I do traffic stats
        #collection using merely iptables, using rules spat out from the makeIptablesRules(interface) method.
        #This works very simply and requires no extra traffic statistics collection apps, just the ability to add
        #iptables rules (root access on the traffic collection machine).
        #In order to get access to the stats generated from iptables, I need to have root access on my gateway machine
        #accessible via this program, and yet if someone steals the SSH keys used by this program they should not be
        #able to do anything malicious.  I achieve this using the command= option in my authorized_keys file on the
        #host that I need to gain controlled root access to.  Using the command= option allows me to specify a string 
        #that is executed as a command when the user logs in with the private key corresponding to the appropriate entry
        #in the authorized_keys file.  I use this to tell it to run the string
        #  "iptables -v -Z -L TABLE"
        #Where TABLE is the name of the table that I need to check, and as you can see it must be done twice per
        #interface - once to check the IN direction and again to check the OUT direction.  Because I have two
        #internet connections, I have 4 lines below, two for each interface.  Note that of course independant keys
        #must be used per command for this method.
        #
        #The security-concious of you will notice that if anyone _does_ steal the keys, they _will_ be able to do
        #mildly malicious things, if you haven't properly secured your SSH server to logins from outside your network.
        #In this case, they may be able to skew your statistics by logging in and zeroing counters, but again this is
        #only if you let them by permitting root logins from non-trusted hosts.
        def getStats
          extend TCD::Common
          Timeout::timeout(30) do
            eth1_in=`/usr/bin/ssh -i #{File.expand_path("~/Documents/Projects/tcd")}/traffic_control_daemon_eth1_in.key root@gir 2>/dev/null`
            eth1_out=`/usr/bin/ssh -i #{File.expand_path("~/Documents/Projects/tcd")}/traffic_control_daemon_eth1_out.key root@gir 2>/dev/null`
            eth2_in=`/usr/bin/ssh -i #{File.expand_path("~/Documents/Projects/tcd")}/traffic_control_daemon_eth2_in.key root@gir 2>/dev/null`
            eth2_out=`/usr/bin/ssh -i #{File.expand_path("~/Documents/Projects/tcd")}/traffic_control_daemon_eth2_out.key root@gir 2>/dev/null`
            { :eth1=>{:in=> toBytes(eth1_in.split("\n")[2].split[1]) , :out=> toBytes(eth1_out.split("\n")[2].split[1])},   
             :eth2=>{:in=> toBytes(eth2_in.split("\n")[2].split[1]) , :out=> toBytes(eth2_out.split("\n")[2].split[1])} }
          end
        end
        #The first day of the billing cycle.
        #My billing cycle rollover date is the eleventh.  If I've downloaded up to 100% of my bandwidth limit and have to stop, on the
        #11th I can start downloading again because the 11th of every month is the first day of my new billing cycle.  So, I'd enter 11.
        #You need to add a rolloverDay for each interface, and it must be in the for of a hash such as {:eth0=>11}.
        def rolloverDay
          {:eth1=>11, :eth2=>1}
        end
        #Must return a hash, one symbol-key per interface, pointing to the number of bytes an interface
        #takes to reach 100% capacity.
        def maxCapacity
          #60GB => Bytes == 64 424 509 440
          {:eth1=>64424509440, :eth2=>64424509440}
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
            return toBytes( (num.chop.to_i * 1024).to_s+"M" )
          when /m$/i
            return toBytes( (num.chop.to_i * 1024).to_s+"K" )
          when /k$/i
            return toBytes( (num.chop.to_i * 1024).to_s )
          else
            return num
          end
        end
      end
    end
  end
end
TCD::Triggers.register( :Gir2, :eth1, 20, ["true", "`touch /home/jeff/penispenispenis`"] )
