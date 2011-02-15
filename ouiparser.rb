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
puts o.whois("00:23:F8:83:56:66")
puts o.whois("00:17:3F:89:4A:89")
puts o.whois("4C:ED:DE:02:71:52")
puts o.whois("7C:C5:37:11:3B:4C")
puts o.whois("F8:DB:7F:72:11:C0")
puts o.whois("00:25:D3:D8:A8:3F")

r = o.grep_organization(/Nokia/)
r.each_pair { |oui, organization| print "#{oui} => "; puts organization}

puts "---------"

r = o.grep_organization(/Apple/)
r.each_pair { |oui, organization| print "#{oui} => "; puts organization}
#o.display
