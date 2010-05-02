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
  module Common
    
    def log msg
      Syslog.open 'Traffic Control Daemon'
      Syslog.notice msg
      Syslog.close
    end
    def writeFile contents, filename, basedir='~/.tcd/', append=nil
      FileUtils.mkdir_p(File.expand_path(basedir)) unless File.exist?(File.expand_path(basedir))
      File.open( File.expand_path(basedir + filename), (append.nil? ? (File::WRONLY|File::TRUNC|File::CREAT) : ("a"))) {|f| f.write contents }
    end
    def readFile filename, maxlines=0
      i=0
      read_so_far=[]
      begin
        f=File.open(File.expand_path(filename), 'r')
        while (line=f.gets)
          break if maxlines!=0 and i >= maxlines
          read_so_far << line and i+=1
        end
      rescue Errno::ENOENT
      end
      read_so_far
    end
    #Return an array containing IP address => subnet mask pairs attached to the interface specified
    #An interface may have more than one IP bound to it.
    def getIPs interface
      return []
    end
    #return an array containing all networks available on an interface
    #determined by looking at each IP and subnet mask on that interface
    def getNetworks interface
      return []
    end
    def getDateTimeFromPath path 
      time=File.basename(path, '.txt')[/^[^_]+/]
      date=File.basename( File.dirname( path ))
      DateTime.parse(date + '_' + time.gsub('-',':'))
    end
    def getDateFromPath path
      DateTime.parse(File.basename(File.dirname(path))) rescue DateTime.parse(File.basename(path))
    end
  end
end
