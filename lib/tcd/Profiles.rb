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
    @profiles=[]
    class << self
      attr_accessor :profiles
      def loadProfiles
        Dir.glob(File.expand_path("~/Documents/Projects/tcd/lib/tcd/profiles/*")).each{|profile_filename|
          if profile_filename[/\.rb\s?$/]
            load profile_filename
            @profiles << eval( "TCD::Profiles::#{File.basename(profile_filename, '.rb').capitalize}" )
            @profiles.uniq!
          end
        }
      end
      #Return true if path should be included in tallying the current billing cycle.
      def PathInCurrentCycle?(profile_name, interface, path)
        extend TCD::Common
        rollover_day= eval("TCD::Profiles::#{profile_name}.rolloverDay")[interface.to_sym]
        path_date= getDateTimeFromPath(path)
        inCurrentCycle?(rollover_day, path_date)
      end
      def DateTimeInCurrentCycle?(profile_name, interface, datetime)
        rollover_day= eval("TCD::Profiles::#{profile_name}.rolloverDay")[interface.to_sym]
        raise 'datetime must be DateTime' unless datetime.class==DateTime
        inCurrentCycle?(rollover_day, datetime)
      end
      #Checks to see if date is within the current billing cycle, using rollover_day
      def inCurrentCycle?(rollover_day, date)
        date >= lastRolloverDate( rollover_day )
      end
      def lastRolloverDate rollover_day
        minus_one= ((DateTime.now.day >= rollover_day) ? 0 : 1)
        DateTime.civil( DateTime.now.year, DateTime.now.month.-(minus_one), rollover_day)
      end
      #Return true only if path points to a dir with stats that need to be aggregated
      def needsAggregating path
        #Note, we are expecting to be passed a path from Dir.glob(".../.tcd/stats/#{p_name}/*/*"), so it should not
        #have a trailing slash.
        return false unless path[/(\d){4}-(\d){1,2}-(\d){1,2}$/] and
          File.directory?(path) and !isToday(path) and
          Dir.glob(path + '/*').each {|stat_file|
            return false unless stat_file[STAT_FILE_REGEX] and
              !stat_file[/aggr\.txt$/]
          }.length > 1
 
        true
      end
      #return true if path's date is today's date
      def isToday(path)
        extend TCD::Common
        date= getDateTimeFromPath(path) rescue getDateFromPath(path)
        now= DateTime.now
        date.day == now.day and date.year == now.year and
          date.month == now.month
      end
      #return true if date in path is the date in date
      def isDay date, path
        extend TCD::Common
        path_date= getDateTimeFromPath(path) rescue getDateFromPath(path)
        path_date.year==date.year and path_date.month==date.month and
          path_date.day==date.day
      end
      #Return an array of all interfaces in a profile
      def getInterfaces profile_name
        interfaces=[]
        eval("TCD::Profiles::#{profile_name.to_s}").rolloverDay.each_key {|k| interfaces << k.to_sym }
        interfaces
      end
      #Return a string representing the current billing cycle, such as
      # '20100211-20100210'
      def billingCycle profile_name
      end
    end
    loadProfiles
  end
end
