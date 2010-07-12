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
    TIMESLICE_BY=3600
    @in_memory_stats=nil
    #@in_memory_stats={ Profile_name => { interface => { :in => [[ i, date ]...],
    #                                                    :out=> [[ i, date ]...]}
    class << self
      attr_accessor :in_memory_stats
      def initMemCounter
        puts "initMemCounter"
        sleep 2
        #{"Gir2"=> {"eth1"=> [] }}
        stats={}
        TCD::Profiles.profiles.each {|profile|
          profile_name=profile.to_s[TCD::MODULE_NAME_REGEX]
          TCD::Profiles.getInterfaces( profile_name ).each {|interface|
            old_stats=TCD::Storage.readStatsFromDisk(profile_name, interface.to_s) {|path| 
              TCD::Profiles.PathInCurrentCycle?(profile_name, interface.to_s, path) 
            }
            old_stats[:in].each {|percent_datetime|
              t=(Time.parse(percent_datetime[1].to_s).to_i / TIMESLICE_BY)
              stats.merge!( {t=>{profile_name=>{interface.to_sym=>{:in=>[], :out=>[]}}}} ) unless stats.has_key? t
              stats[t].merge!( {profile_name=>{interface.to_sym=>{:in=>[], :out=>[]}}} ) unless stats[t].has_key? profile_name
              stats[t][profile_name].merge!( {interface.to_sym=>{:in=>[], :out=>[]}} ) unless stats[t][profile_name].has_key? interface.to_sym
              stats[t][profile_name][interface.to_sym][:in] << percent_datetime
              
            }
            old_stats[:out].each {|percent_datetime|
              t=(Time.parse(percent_datetime[1].to_s).to_i / TIMESLICE_BY)
              stats.merge!( {t=>{profile_name=>{interface.to_sym=>{:in=>[], :out=>[]}}}} ) unless stats.has_key? t
              stats[t].merge!( {profile_name=>{interface.to_sym=>{:in=>[], :out=>[]}}} ) unless stats[t].has_key? profile_name
              stats[t][profile_name].merge!( {interface.to_sym=>{:in=>[], :out=>[]}} ) unless stats[t][profile_name].has_key? interface.to_sym
              stats[t][profile_name][interface.to_sym][:out] << percent_datetime
            }
          }
        }
        stats
      end
      #Store the results of running getAllProfileStats
      def saveStats stats
        puts "saveStats"
        require 'pp'
        pp stats
        writeStatsToMemory stats
      end
      #Read stats, using the block provided to determine if the record should be included
      #assuming a block is provided
      def readStats profile_name, interface, use_sums=nil, more=false, &blk
        puts "readStats"
        readStatsFromMemory profile_name, interface, use_sums, more, &blk
      end
      #Save stats to disk in a ~/.tcd/stats/$profile_name/$if/$timestamp.yaml manner
      def saveStatsToDisk stats
        puts "saveStatsToDisk"
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
      def readStatsFromDisk profile_name, interface, use_sums=nil, more=nil, &blk
        require 'pp'
        pp caller
        puts "readStatsFromDisk #{profile_name} #{interface} #{use_sums}"
        values={:in=>[],:out=>[]}
        Dir.glob(File.expand_path("~/.tcd/stats/#{profile_name}/#{interface}/**/*")).each {|path|
          next unless path[STAT_FILE_REGEX]
          result=processStat(path) if yield(path)
          unless result.nil?
            if result.class==Hash and result[:in][0][1]==:sum and result[:out][0][1]==:sum
              #aggregate file
              use_sums ? ((values[:in] << result[:in][0]) and (values[:out] << result[:out][0])) : 
                ((result[:in][1..(result[:in].size)].each {|p_d| values[:in] << p_d}  ) and (result[:out][1..(result[:out].size)].each {|p_d| values[:out] << p_d}  ) )

              next
            end
            result[0]==:in ? values[:in] << result[1] : values[:out] << result[1]
          end
        }
        values
      end
      def readStatsFromMemory profile_name, interface, use_sums, more_than_this_cycle=false, &blk
        puts "readStatsFromMemory"
        @in_memory_stats=initMemCounter if @in_memory_stats.nil?
        return readStatsFromDisk(profile_name, interface, use_sums, &blk) if more_than_this_cycle
        stats={:in=>[],:out=>[]}
        @in_memory_stats.each_key {|t|
          @in_memory_stats[t][profile_name.to_s][interface.to_sym][:in].each {|percent_datetime|
            stats[:in] << percent_datetime
          }
          @in_memory_stats[t][profile_name.to_s][interface.to_sym][:out].each{|percent_datetime|
            stats[:out] << percent_datetime
          }
          #stats[:in] << @in_memory_stats[t][profile_name.to_s][interface.to_sym][:in]
          #stats[:out]<< @in_memory_stats[t][profile_name.to_s][interface.to_sym][:out]
        }
        stats
      end
      def writeStatsToMemory stats
        puts 'writeStatsToMemory'
        saveStatsToDisk stats
        @in_memory_stats=initMemCounter if @in_memory_stats.nil?
        stats.each_key {|profile_name|
          timestamp= DateTime.parse( stats[profile_name][:timestamp].to_s.gsub(/-\d{4}/,'') )  #remove timezone offset
          t= (Time.parse(timestamp.to_s).to_i / TIMESLICE_BY) 
          stats[profile_name].each_key {|interface|
            next if interface==:timestamp
            
            @in_memory_stats=Hash.new if @in_memory_stats.nil?
            @in_memory_stats[t]=Hash.new if @in_memory_stats.nil?
            @in_memory_stats[t][profile_name.to_s]=Hash.new if @in_memory_stats[t][profile_name.to_s].nil?
            @in_memory_stats[t][profile_name.to_s][interface]=Hash.new if @in_memory_stats[t][profile_name.to_s][interface].nil?
            @in_memory_stats[t][profile_name.to_s][interface][:in]= Array.new if @in_memory_stats[t][profile_name.to_s][interface][:in].nil?
            @in_memory_stats[t][profile_name.to_s][interface][:out]= Array.new if @in_memory_stats[t][profile_name.to_s][interface][:out].nil?

            @in_memory_stats[t][profile_name.to_s][interface][:in] << [stats[profile_name][interface][:in],timestamp.to_s]
            @in_memory_stats[t][profile_name.to_s][interface][:out] <<[stats[profile_name][interface][:out],timestamp.to_s]
          }
        }
        cleanInMemCounters
      end
      def cleanInMemCounters
        puts 'cleanInMemCounters'
        extend Profiles
        return nil if @in_memory_stats.nil?
        @in_memory_stats.each_key {|profile_name|
          @in_memory_stats[profile_name].each_key {|interface|
            next if @in_memory_stats[profile_name][interface]==:timestamp
            #remove out of cycle bandwidth=>date sets
            @in_memory_stats[profile_name][interface]=@in_memory_stats[profile_name][interface].each_pair {|direction, dates|
              
              @in_memory_stats[profile_name][interface][direction].delete_if {|stat_dates|
                date=stat_dates[1]
                !Profiles.dateTimeInCurrentCycle?(profile_name, interface, DateTime.parse(date))
              } unless @in_memory_stats[profile_name][interface][direction].empty?
            }
          }
        }
      end
      #Read path, and generate a list of stats from it.
      def processStat path
        result=[]
        return(readAggStat(path)) if path.include?('aggr')
        File.basename(path).include?('in') ? (result[0]=:in) : (result[0]=:out)
        result[1]=readOneStat(path)
        return result
      end
      #Read a stat file containing one integer, the number of bytes transfered at that time.
      def readOneStat path
        extend TCD::Common
        [readFile(path)[0].to_i, getDateTimeFromPath(path).to_s]
      end
      def readAggStat path
        extend TCD::Common
        YAML.load readFile(path).join
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
        trigger_log={:all=>{:all=>[]}} unless trigger_log
        trigger_log.each_key {|profile|
          trigger_log[profile].each_key {|interface|
            next unless trigger_log[profile][interface].length > 0
            trigger_log[profile][interface][0]= DateTime.parse(trigger_log[profile][interface][0].to_s)
          }
        }
        trigger_log
      end
      def writeTriggerLog
        extend Common
        writeFile( YAML.dump(Triggers.trigger_log), 'trigger_log.yaml' )
      end
      #Write the trigger update log to disk
      def readTriggerUpdateLog
        extend Common
        trigger_update_log=Triggers.trigger_update_log=( YAML.load(readFile( '~/.tcd/trigger_update_log.yaml' ).join) rescue {:all=>{:all=>[]}})
        #Convert Time to DateTime
        trigger_update_log={:all=>{:all=>[]}} unless trigger_update_log
        trigger_update_log.each_key {|profile|
          trigger_update_log[profile].each_key {|interface|
            next unless trigger_update_log[profile][interface].length > 0
            trigger_update_log[profile][interface][0]= DateTime.parse(trigger_update_log[profile][interface][0].to_s)
          }
        }
        trigger_update_log
      end
      def writeTriggerUpdateLog
        extend Common
        writeFile( YAML.dump(Triggers.trigger_update_log), 'trigger_update_log.yaml' )
      end
    end
  end
end
