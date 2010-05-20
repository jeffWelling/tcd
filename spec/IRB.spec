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
require 'time'

describe IRB do
  before :each do
    TestLibrary.resetRuncount
    Triggers.trigger_log=[]
  end
  before :all do
    $profile="Foobar".to_sym
    $interface=:eth0
    $percent=42
    $rules=["true",'TestLibrary.setRun']
    _defmethod($profile.to_sym, $interface.to_sym, 1, 1, 1, 200)
    
  end
  it "Gets all profile stats for all profiles and saves them"
  it "returns the usage for this billing cycle"
  it "returns the percent of capacity used so far in this billing cycle"
  it "Aggregates all data"
  it "Aggregate all data for profile_name and interface" do
    time=nil
    seconds_between_statfiles=30
    n=((60 * 60 * 24 ) / seconds_between_statfiles)
    n_n=0
    in_counter=0
    out_counter=0
    n.times do
      time=Time.parse("May 17 2009 0:00:00").+(n_n+=seconds_between_statfiles)     #An arbitrary date, starting at 0:00:00
      stats={ :Foobar=> {
        :timestamp=>time,
        :eth1=>{ :in=>1, :out=> 1}}
       }
      in_counter+=1
      out_counter+=1
      Storage.saveStatsToDisk stats
    end
    read_stats=Storage.readStats(:Foobar, :eth1) { true }
    (read_stats[:in].size + read_stats[:out].size).should == in_counter+out_counter
    
    puts in_counter+out_counter
#    FileUtils.rm_rf File.expand_path("~/.tcd/stats/Foobar")
  end
  it "runs all triggers" do
    #We don't want to run the actual profiles, so wipe them out
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
    _defmethod(p1.to_sym, i1.to_sym, 1, 1, 1, 200)
    _defmethod(p2.to_sym, i2.to_sym, 1, 1, 1, 200)
    _defmethod(p3.to_sym, i3.to_sym, 1, 1, 1, 200)
    Triggers.register( p1, i1, pc1, $rules )
    Triggers.register( p2, i2, pc2, $rules )
    Triggers.register( p3, i3, pc3, $rules )
    Triggers.register( p3, i3, pc4,  $rules )
    Triggers.trigger_log.should == []
    IRB.runTriggers
    TestLibrary.ran?.should_not == 0

    15.times do
      sleep 1
      IRB.getAllProfileStats
    end
    IRB.runTriggers

    Profiles.profiles.each {|p|
      p_name="#{p}"[MODULE_NAME_REGEX]
      Profiles.getInterfaces(p_name).each {|i|
      }
    }
    Triggers.trigger_log.should_not == []
  end
end
