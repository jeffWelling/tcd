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
  class Triggers
    #triggers={ :profile_name =>
    #           { :interface =>
    #             { :percent =>
    #               [ cmd1, cmd2, cmd3, ...] }}}
    #     Where cmd1,2,3... and so on are the commands to be executed sequentially after that percent 
    #     of capacity has been reached on that interface in that profile for the current billing
    #     period.
    @triggers={}
    @trigger_log=false
    class << self
      
      attr_reader :triggers
      attr_accessor :trigger_log
      #Register *rules under profile_name, interface, and percent.
      #This is called by the user to register the rules they want and when they want to run them.  It
      # should be called from the user written profile. 
      def register profile_name, interface, percent, *rules
        profile_name=profile_name.to_sym
        interface=interface.to_sym

        #prep @triggers if it needs it
        @triggers.merge!( {profile_name => {}} ) unless @triggers.include?( profile_name )
        @triggers[profile_name].merge!( {interface => {}} ) unless 
          @triggers[profile_name].include?( interface )
        @triggers[profile_name][interface].merge!( {percent=>[]} ) unless
          @triggers[profile_name][interface].include?( percent )
        
        #Is rules just one set of rules, or is it an array of rules
        if rules[0].class==String
          @triggers[profile_name][interface][percent] << rules
        else
          rules.each {|rule| @triggers[profile_name][interface][percent] << rule }
        end
      end

      #Run any triggers associated with this percent for this interface on this profile_name
      #Intended to be run from IRB.process_triggers
      def update profile_name, interface, percent
        profile_name=profile_name.to_sym
        interface=interface.to_sym
        
        @triggers[profile_name][interface][percent].each {|rules|
          (eval(rules[1]); log(profile_name,interface,percent)) if eval(rules[0]).class==TrueClass
        } rescue return(false)
        true
      end

      #log the percent that this trigger was run at so we know what we've missed
      #on the next run.
      def logTrigger profile_name, interface, percent
        @trigger_log.merge!( profile_name=>{} ) unless @trigger_log.include?(profile_name)
        @trigger_log[profile_name].merge!( interface=>false ) unless @trigger_log.include?(interface)
        @trigger_log[profile_name][interface]= [DateTime.now, percent]
        Storage.writeTriggerLog
      end

      #get the percentage (as an int) that the profile/interface/percent was last run at
      #If the last time the trigger was run was in the last billing cycle, 0 will be returned.
      #If the trigger has never been run before, it will return zero.
      def getLastRunUsage profile_name, interface
        profile_name=profile_name.to_sym
        interface=interface.to_sym
        @trigger_log||=Storage.readTriggerLog
        trigger=@trigger_log[profile_name][interface] rescue return(0)
        rollover_day=eval("Profiles::#{profile_name.to_s.capitalize}.rolloverDay[:#{interface}]")
        Storage.writeTriggerLog
        Profiles.inCurrentCycle?( rollover_day, trigger[0] ) ? trigger[1] : 0
      end

      #return true if cmd has already been executed on schedule in this billing period
      def alreadyDone?( profile_name, interface, cmd )
      end
    end
  end
end
