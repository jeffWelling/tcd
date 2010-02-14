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
            dir=File.expand_path("~/.tcd/stats/#{profile_name}/#{interface}/#{Time.now.year}-#{Time.now.month}/")
            FileUtils.mkdir_p dir
            writeFile( stats[profile_name][interface][:in], Time.now.strftime("%H-%M-%S")+".txt", '~/.tcd/', :append )
            writeFile( stats[profile_name][interface][:out],Time.now.strftime("%H-%M-%S")+".txt", '~/.tcd/', :append )
          }
        }
      end
    end
  end
end
