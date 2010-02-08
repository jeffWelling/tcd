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
    #Retrieve bandwidth statistics from pmacct
    def retrieveData
      getBytes(`ssh -i traffic_control_daemon_in.key gir 2>/dev/null`).to_i + 
      getBytes(`ssh -i traffic_control_daemon_out.key gir 2>/dev/null`).to_i
    end
    def getBytes src_str
      src_str.split("\n")[1].split(' ')[2].strip
    end
  end
end
