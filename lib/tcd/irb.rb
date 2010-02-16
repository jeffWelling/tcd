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
  module IRB
    class << self
      include TCD::Profiles
      def getAllProfileStats
        result={}
        PROFILES.each {|profile|
          stats_plus_timestamp=profile.getStats.merge({:timestamp=>Time.now})
          result.merge!({"#{profile}"[/[^:]+?$/].to_sym => stats_plus_timestamp}) if profile.useProfile?
        }
        result
      end
      #Return the total number of bytes used this billing cycle
      def usageThisBillingPer profile_name, interface
        
      end
    end
  end
end
