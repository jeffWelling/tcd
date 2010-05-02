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
  before(:each) do
    module TCD
      module Profiles
        module TestProfile
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
        end
      end
    end
  end
  it "loads profiles" do
    File.copy("spec/testprofileone.rb", "lib/tcd/profiles/testprofileone.rb")
    failed=false
    TCD::Profiles.loadProfiles
    TCD::Profiles::Testprofileone rescue failed=true
    File.delete("lib/tcd/profiles/testprofileone.rb")
    failed.should == false
  end
  it "returns true if path should be included in tallying this billing cycle" do
    date= DateTime.civil( DateTime.now.year, 
      DateTime.now.day < TCD::Profiles::TestProfile.rolloverDay[:eth0] ? (DateTime.now.month - 1) : (DateTime.now.month) ,
      TCD::Profiles::TestProfile.rolloverDay[:eth0])
    path=makePathWithDate( date, :in )
    TCD::Profiles.inCurrentCycle( :TestProfile, :eth0, path ).should == true


    date= DateTime.civil( DateTime.now.year, 
      DateTime.now.day < TCD::Profiles::TestProfile.rolloverDay[:eth0] ? (DateTime.now.month - 1) : (DateTime.now.month) ,
      TCD::Profiles::TestProfile.rolloverDay[:eth0] - 1)
    path=makePathWithDate( date, :in )
    TCD::Profiles.inCurrentCycle( :TestProfile, :eth0, path).should == false
  end
  it "extracts the datetime from the path" do
    date= DateTime.civil( 2010, 4, 20, 4, 20, 4)
    path=makePathWithDate( date, :in )
    date_from_path=TCD::Profiles.getDateTimeFromPath(path)
    date_from_path.year.should==2010
    date_from_path.month.should==4
    date_from_path.day.should==20
    date_from_path.hour.should==4
    date_from_path.min.should==20
    date_from_path.sec.should==4
  end
  it "extracts the date from the path" do
    date= DateTime.civil( 2010, 4, 20)
    path=makePathWithDate( date, :in )
    date_from_path=TCD::Profiles.getDateFromPath(path)
    date_from_path.year.should==2010
    date_from_path.month.should==4
    date_from_path.day.should==20
  end
  it "given rollover_day, returns DateTime object representing start of this billing cycle" do
    rollover_day= TCD::Profiles.lastRolloverDate( DateTime.now.day )
    #FIXME these will go all foobar around the end of the month, and the end of the year.
    TCD::Profiles.lastRolloverDate( DateTime.now.day - 1 ).month.should== DateTime.now.month
    TCD::Profiles.lastRolloverDate( DateTime.now.day ).month.should== DateTime.now.month
    TCD::Profiles.lastRolloverDate( DateTime.now.day + 1 ).month.should== DateTime.now.month - 1
  end
  it "Return true only if path points to a dir with stats that need to be aggregated"
  it "return true if path's date is today's date"
end
