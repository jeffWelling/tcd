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
    PROFILES=[]
    class << self
      def loadProfiles
        Dir.glob(File.expand_path("~/Documents/Projects/tcd/lib/tcd/profiles/*")).each{|profile_filename|
          if profile_filename[/\.rb\s?$/]
            load profile_filename
            PROFILES << eval( "TCD::Profiles::#{File.basename(profile_filename, '.rb').capitalize}" )
            PROFILES.uniq!
          end
        }
      end
      #Return true if path should be included in tallying the current billing cycle.
      def inCurrentCycle(profile_name, interface, path)
        rollover_day= eval("TCD::Profiles::#{profile_name}.rolloverDay")[interface]
        path_date= getDateFromPath(path)
        now=DateTime.now
        first_day_of_billing_cycle=lastRolloverDate( rollover_day )
        path_date > first_day_of_billing_cycle
      end
    end
    loadProfiles
  end
end
