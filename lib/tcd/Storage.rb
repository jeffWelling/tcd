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
      #Save stats to disk in a ~/.tcd/stats/$profile_name/$if/$timestamp.yaml manner
      def saveStatsToDisk stats
        extend TCD::Common
        stats.each_key {|profile_name|
          stats[profile_name].each_key {|interface|
            next if interface==:timestamp
            dir= "~/.tcd/stats/#{profile_name}/#{interface}/#{Time.now.year}-#{Time.now.month}-#{Time.now.day}/"
            writeFile( stats[profile_name][interface][:in], Time.now.strftime("%H-%M-%S")+"_in.txt", dir, :append )
            writeFile( stats[profile_name][interface][:out],Time.now.strftime("%H-%M-%S")+"_out.txt", dir, :append )
          }
        }
      end
      #Read stats from ~/.tcd/stats for profile_name and interface.  The block passed each path
      #in succession and must return true if that path should be read and included in the tally
      #returned to the user.
      def readStats profile_name, interface, &blk
        values={:in=>[],:out=>[]}
        Dir.glob(File.expand_path("~/.tcd/stats/#{profile_name}/#{interface}/**/*")).each {|path|
          next unless path[/(\d){4}-(\d){1,2}-(\d){1,2}\/(\d){1,2}-(\d){1,2}-(\d){1,2}_(in|out|aggr)\.txt/]
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
        time=File.basename(path, '.txt')[/^[^_]+/]
        date=File.basename( File.dirname( path ))
        [readFile(path)[0].to_i, DateTime.parse(date + '_' + time).to_s]
      end
      #Read an aggregated stat file, containing a combination of integers to timestamps.
      #The integers being the number of bytes transferred at that timestamp.
      def readAggrStats path
      end
    end
  end
end
