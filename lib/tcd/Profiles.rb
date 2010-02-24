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
        rollover_day= eval("TCD::Profiles::#{profile_name}.rolloverDay")[interface.to_sym]
        path_date= getDateTimeFromPath(path)
        now=DateTime.now
        first_day_of_billing_cycle=lastRolloverDate( rollover_day )
        path_date >= first_day_of_billing_cycle
      end
      def getDateTimeFromPath path
        DateTime.parse(File.basename(File.dirname(path)) + ' ' + File.basename(path, '.txt')[/^[^_]+/].gsub('-',':')) rescue puts(
        File.basename(File.dirname(path)) + ' ' + File.basename(path, '.txt')[/^[^_]+/].gsub('-',':'))
      end
      def getDateFromPath path
        DateTime.parse(File.basename(File.dirname(path))) rescue DateTime.parse(File.basename(path))
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
        date= Storage.getDateTimeFromPath(path) rescue getDateFromPath(path)
        now= DateTime.now
        date.day == now.day and date.year == now.year and
          date.month == now.month
      end
      #return true if date in path is the date in date
      def isDay date, path
        path_date= Storage.getDateTimeFromPath(path) rescue getDateFromPath(path)
        path_date.year==date.year and path_date.month==date.month and
          path_date.day==date.day
      end
      def getInterfaces profile_name
        interfaces=[]
        eval("TCD::Profiles::#{profile_name.to_s}").rolloverDay.each_key {|k| interfaces << k }
        interfaces
      end
    end
    loadProfiles
  end
end
