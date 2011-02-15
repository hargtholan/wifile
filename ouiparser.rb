#This file is part of Wifile.
#
# Copyright (C) 2011 Juan V. Puertos Ahuir <juanvi.puertos@gmail.com>
#
#    Wifile is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    Wifile is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with Wifile.  If not, see <http://www.gnu.org/licenses/>.

#
# oui => vendor, country
#
#

require 'ostruct'

class OuiTable

  @oui_table = Hash.new

  def initialize
    @oui_table = Hash.new
  end
  
  def parse(input)
    while line = input.gets
      if line =~ /^([0-9a-fA-F]{2}\-){2}[0-9a-fA-F]{2}/
        oui = $&.gsub(/\-/, ":")
        line =~ /\t+.+/
        organization = $&[2,$&.length]
        @oui_table[oui] = organization
      end
    end
  end

  def whois(mac)
    return @oui_table[mac[0,8]]
  end

  def grep_organization(regexp)
    result = Hash.new
    @oui_table.each_pair do |oui, organization|
      if organization =~ /#{regexp}/
        result[oui] = organization
      end
    end
    return result
  end
  
  def display
    @oui_table.each_pair { |oui, organization| print "#{oui} => "; puts organization}
  end

end

f = File.open("oui.txt", "rb")
o = OuiTable.new
o.parse(f)

