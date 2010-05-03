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
require 'ftools'

module TestLibrary
  def makePathWithDate date, direction, path=nil
    raise unless direction==:in or direction==:out or direction==:aggr
    (path.nil? ? ("/foo/bar/delicious/weenies/") : (path) )+"#{date.year}-#{date.month}-#{date.day}/#{date.hour}-#{date.min}-#{date.sec}_#{direction.to_s}.txt"
  end
  #mktempdir(prefix = 'TCD') will return a temp directory.
  #This directory is not yet, but should be auto-deleted on exit
  def mktempdir str = 'TCD'
    str += '.XXXXXX' unless str =~ /X+$/
    `mktemp -td #{str}`.strip # Is there a better way?
  end
	
  def rand_file_name
    chars = ('a'..'z').collect + ('A'..'Z').collect + ('0'..'9').collect
    name = (rand(6) + 2).of { chars.random }.join
  end
end
