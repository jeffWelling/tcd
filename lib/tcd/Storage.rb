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
  module Storage
    class << self
      #Store the results of running getAllProfileStats
      def saveStats stats
        saveStatsToDisk stats
      end
      #Read stats, using the block provided to determine if the record should be included
      #assuming a block is provided
      def readStats profile_name, interface, &blk
        readStatsFromDisk profile_name, interface, &blk
      end
      #Save stats to disk in a ~/.tcd/stats/$profile_name/$if/$timestamp.yaml manner
      def saveStatsToDisk stats
        extend TCD::Common
        stats.each_key {|profile_name|
          timestamp= stats[profile_name][:timestamp]
          stats[profile_name].each_key {|interface|
            next if interface==:timestamp
            dir= "~/.tcd/stats/#{profile_name}/#{interface}/#{timestamp.year}-#{timestamp.month}-#{timestamp.day}/"
            writeFile( stats[profile_name][interface][:in], timestamp.strftime("%H-%M-%S")+"_in.txt", dir, :append )
            writeFile( stats[profile_name][interface][:out],timestamp.strftime("%H-%M-%S")+"_out.txt", dir, :append )
          }
        }
      end
      #Read stats from ~/.tcd/stats for profile_name and interface.  The block passed each path
      #in succession and must return true if that path should be read and included in the tally
      #returned to the user.
      def readStatsFromDisk profile_name, interface, &blk
        values={:in=>[],:out=>[]}
        Dir.glob(File.expand_path("~/.tcd/stats/#{profile_name}/#{interface}/**/*")).each {|path|
          next unless path[STAT_FILE_REGEX]
          result=processStat(path) if yield(path)
          unless result.nil?
            result[0]==:in ? values[:in] << result[1] : values[:out] << result[1]
          end
        }
        values
      end
      #Read path, and generate a list of stats from it.
      def processStat path
        result=[]
        File.basename(path).include?('in') ? (result[0]=:in) : (result[0]=:out)
        result[1]=readOneStat(path)
        return result
      end
      #Read a stat file containing one integer, the number of bytes transfered at that time.
      def readOneStat path
        extend TCD::Common
        [readFile(path)[0].to_i, getDateTimeFromPath(path).to_s]
      end
      #Read an aggregated stat file, containing a combination of integers to timestamps.
      #The integers being the number of bytes transferred at that timestamp.
      def readAggrStats path
        extend TCD::Common
        YAML.load readFile(path).join
      end
      def postAggDeletion path
        count=0
        extend TCD::Common
        Dir.glob(path+ '/*').each {|p|
          (File.delete(p) and count+=1) if p[STAT_FILE_REGEX] and p[/00-00-00_aggr\.txt$/].nil?
        }
        count
      end
      #Write the trigger log to disk
      def readTriggerLog
        extend Common
        trigger_log=Triggers.trigger_log=( YAML.load(readFile( '~/.tcd/trigger_log.yaml' ).join) rescue {:all=>{:all=>[]}})
        #Convert Time to DateTime
        trigger_log.each_key {|profile|
          trigger_log[profile].each_key {|interface|
            trigger_log[profile][interface][0]= DateTime.parse(trigger_log[profile][interface][0].to_s)
          }
        }
        trigger_log
      end
      def writeTriggerLog
        extend Common
        writeFile( YAML.dump(Triggers.trigger_log), 'trigger_log.yaml' )
      end
    end
  end
end
