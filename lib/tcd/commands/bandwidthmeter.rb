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
  module Command
    module BandwidthMeter
      def parser(o)
        o.banner= "Usage: tcd (bwmeter|bandwidthmeter|meter) [options] Shows the amount of bandwidth used in this billing cycle"
        o.on_head(
          "-p PROFILE_NAME", "--profile PROFILE_NAME", "Specify the profile name to check statistics for"){|v|
          options.profile= v
        }
        o.on_head(
          "-i INTERFACE", "--interface INTERFACE", "Which interface to tally bandwidth usage for"){|v|
          options.interface= v
        }
      end
      def execute
        puts "Total bandwidth used in this billing cycle is #{TCD::IRB.usageThisBillingPer(options.profile, options.interface)} Bytes."
      end
    end
  end
end 
