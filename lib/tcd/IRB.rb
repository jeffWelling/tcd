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
        Profiles.profiles.each {|profile|
          if profile.useProfile?
            stats_plus_timestamp=profile.getStats.merge({:timestamp=>Time.now})
            result.merge!({"#{profile}"[/[^:]+?$/].to_sym => stats_plus_timestamp})
          end
        }
        TCD::Storage.saveStats result
        result
      end
      #Return the total number of bytes used this billing cycle
      def usageThisBillingPer profile_name, interface
        stats= TCD::Storage.readStats(profile_name, interface) {|path| TCD::Profiles.PathInCurrentCycle?(profile_name, interface, path) }
        bytes_in=0
        bytes_out=0
        stats[:in].each {|size, date| bytes_in+=size}
        stats[:out].each{|size, date| bytes_out+=size}
        bytes_in+bytes_out
      end
      def usageSinceEpoc profile_name, interface
        stats= TCD::Storage.readStats(profile_name, interface, true) {|path| true }
        bytes_in=0
        bytes_out=0
        stats[:in].each {|size, date| bytes_in+=size}
        stats[:out].each{|size, date| bytes_out+=size}
        bytes_in+bytes_out
      end
      #Return an integer representing the percent of capacity used on interface according to profile
      def percentOfCapacity profile_name, interface
        usage=usageThisBillingPer(profile_name, interface) + 0.00
        capacity=eval("TCD::Profiles::#{profile_name.to_s}.maxCapacity()")[interface.to_sym]
        raise "profile has no #{interface}" if capacity.nil?
        ((usage/capacity).to_s[/^\d+\.\d(\d)?/].to_f * 100).to_i
      end
      def aggregateAll
        Profiles.profiles.each {|profile|
          aggregate profile.to_s[MODULE_NAME_REGEX]
        }
      end
      #Aggregate stats for profile_name, optionally restricted to only stats for interface
      def aggregate profile_name, interface=nil
        extend TCD::Common
        count=0
        Dir.glob(File.expand_path("~/.tcd/stats/#{profile_name}/#{interface || '*'}/*")).each {|path|
          next unless TCD::Profiles.needsAggregating(path)
          day= getDateFromPath(path)
          interface= File.basename(File.dirname(path))
          stats= TCD::Storage.readStats(profile_name, interface) {|p| TCD::Profiles.isDay(day,p) }
          in_sum= out_sum= 0
          stats[:in].each {|size, date| in_sum+=size }
          stats[:out].each {|size, date| out_sum+=size }
          stats[:in]= [[in_sum, :sum]] + stats[:in]
          stats[:out]=[[out_sum,:sum]] + stats[:out]
          writeFile YAML.dump(stats), '00-00-00_aggr.txt', path+'/'
          TCD::Storage.postAggDeletion( path )
          count+=1
        }
        count
      end

      #Run all triggers scheduled to run between the last time this was called and now.
      def runTriggers
        Profiles.profiles.each {|m|
          mod=m.to_s[MODULE_NAME_REGEX]
          TCD::Profiles.getInterfaces(mod).each {|interface|
            #For every percent point between now and last run, do
            #   Triggers.update
            current_usage= percentOfCapacity mod, interface
            last_usage= Triggers.getLastRunUsage( mod.to_sym, interface)
            
            (last_usage..current_usage).each {|percent|
              TCD::Triggers.update( mod, interface, percent )
            }
          }
        }
      end
    end
  end
end
