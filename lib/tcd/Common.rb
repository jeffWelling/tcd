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
    def writeFile contents, filename, append=nil
      FileUtils.mkdir(File.expand_path('~/.tcd/')) unless File.exist?(File.expand_path(Storage.basedir))
      File.open( File.expand_path(filename), (append.nil? ? (File::WRONLY|File::TRUNC|File::CREAT) : ("a"))) {|f| f.write contents }
    end
    #Retrieve bandwidth statistics from pmacct
    def retrieveData _module
      _module.getStats
    end
    def getBytes src_str
      src_str.split("\n")[1].split(' ')[2].strip
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
  end
end
