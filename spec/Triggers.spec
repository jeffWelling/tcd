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

describe Triggers do
  before :each do
    TestLibrary.resetRuncount
    Profiles.profiles=[]
  end
  before :all do
    $profile="Foobar".to_sym
    $interface=:eth0
    $percent=42
    $rules=["true",'TestLibrary.setRun']
    _defmethod $profile, $interface, 4, 4, 1, 200
  end
  it "registers a set of rules" do 
    #rules should not yet be registered
    failed=false
    begin
      Triggers.triggers[$profile][$interface][$percent]
    rescue
      failed=true
    end
    failed.should == true
    #rules should be registered
    Triggers.register( $profile, $interface, $percent, $rules )
    failed=false
    begin
      Triggers.triggers[$profile][$interface][$percent]
    rescue
      failed=true
    end
    failed.should == false
  end
  it "Runs the triggers registered to run at the specified percent" do
    Triggers.register( $profile, $interface, $percent, $rules )
    Triggers.update( $profile, $interface, $percent )
    TestLibrary.ran?.should == true
  end
  it "log that a trigger was run" do
    Triggers.logTrigger( $profile, $interface, 44 )
    Triggers.trigger_log.include?($profile).should == true
    Triggers.trigger_log[$profile].include?($interface).should == true
    Triggers.trigger_log[$profile][$interface].length.should == 2
    Triggers.trigger_log[$profile][$interface][1].should == 44
  end
  it "get the percent that profile/interface was last triggered at" do
    Triggers.register( $profile, $interface, $percent, $rules )
    #Note that calling register is only here because without it, $profile doesn't get defined.
    Triggers.logTrigger( $profile, $interface, 42 )
    Triggers.getLastTriggerRun( $profile, $interface ).should == 42
  end
end
