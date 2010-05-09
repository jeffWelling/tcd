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

describe IRB do
  before :each do
    TestLibrary.resetRuncount
  end
  before :all do
    $profile=("X"+ rand_file_name().capitalize).to_sym
    $interface=:eth0
    $percent=42
    $rules=["true",'TestLibrary.setRun']
    module TCD
      module Profiles
        mod="module #{$profile}
          class << self
            def useProfile?
              true
            end
            def getStats
              {:eth0=> {:in=> 1, :out=> 1}}
            end
            def rolloverDay
              {:eth0=> 11}
            end
            def maxCapacity
              {:eth0=>420}
            end
          end
        end"
      eval mod
      end
    end
  end
  it "Runs all triggers scheduled to run between last run and now" do
    Triggers.register( $profile, $interface, ($percent - 20), $rules )
    Triggers.register( $profile, $interface, $percent, $rules)
    Triggers.register( $profile, $interface, ($percent + 20), $rules )
    Triggers.trigger_log.should == false
    IRB.runTriggers
    Triggers.trigger_log.should == false
  end
end
