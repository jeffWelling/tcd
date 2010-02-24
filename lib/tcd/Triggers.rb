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
    class << self
      
      attr_reader :triggers
      
      #Run any triggers associated with this percent for this interface on this profile_name
      def update profile_name, interface, percent
        @triggers.merge!( { profile_name.to_sym => {}} ) unless @triggers.has_key? profile_name.to_sym
        @triggers[profile_name.to_sym].merge!( { interface.to_sym => {} } ) unless @triggers.has_key? interface.to_sym
        @triggers[profile_name.to_sym][interface.to_sym].merge!(
          { percent => [] }) unless @triggers[profile_name.to_sym][interface.to_sym].has_key? percent

        @triggers[profile_name.to_sym][interface.to_sym][percent].each {|cmd|
          #execute cmd
        }
      end
      #return true if cmd has already been executed on schedule in this billing period
      def alreadyDone?( profile_name, interface, cmd )
      end
    end
  end
end
