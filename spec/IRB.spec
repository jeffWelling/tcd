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
              {:eth0=> {:in=> rand(200), :out=> rand(200)}}
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
  it "runs all triggers" do
    Profiles.profiles=[]
    p1= $profile.to_s+'1'
    p2= $profile.to_s+'2'
    p3= $profile.to_s+'3'
    i1= $interface.to_s+'1'
    i2= $interface.to_s+'2'
    i3= $interface.to_s+'3'
    pc1= 1
    pc2= 50
    pc3= 99
    pc4= 100
    Triggers.register( p1, i1, pc1, $rules )
    Triggers.register( p2, i2, pc2, $rules )
    Triggers.register( p3, i3, pc3, $rules )
    Triggers.register( p3, i3, pc4,  $rules )
    require 'pp'
    puts "\n"
    pp Triggers.triggers
    puts "\n"
    Triggers.trigger_log.should == false
    IRB.runTriggers
    TestLibrary.ran?.should_not == 0
    pp Triggers.trigger_log
    pp TestLibrary.ran?
    Triggers.trigger_log.should_not ==  false
    
  end
end
