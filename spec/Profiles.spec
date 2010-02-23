#  Copyright 2009, Jeff Welling
#
#    This file is part of Traffic Control Daemon (aka, tcd).
#
#    Traffic Control Daemon is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Traffic Control Daemon is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Traffic Control Daemon.  If not, see <http://www.gnu.org/licenses/>.

 
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../spec"))
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"))

load 'lib/tcd.rb'
include TCD
load 'TestLibrary.rb'
include TestLibrary

describe Profiles do
  it "loads all profiles"
  it "returns true if path should be included in tallying this billing cycle" do
    module TCD
      module Profiles
        module Gir
          class << self
            def useProfile?
              true
            end
            def getStats
              {:eth0=> {:in=> rand(200), :out=> rand(200)}}
            end
            def rolloverDay
              {:eth0=> 10}
            end
          end
        end
      end
    end
  end
  it "extracts the date from the path"
  it "given rollover_day, returns DateTime object representing start of this billing cycle"
end
