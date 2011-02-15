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


#!/usr/bin/ruby1.8 -w

require 'ostruct'

def query_channels(iface = "wlan0")
  freq_table = Hash.new
  channels = IO.popen("iwlist #{iface} channel")
  while line = channels.gets
    if line =~ /Channel\s/
      $' =~ /\d+/
      channel = $&
      line =~ /\d+\.\d+/
      freq_table[channel] = $&
    end
    if line =~ /\(Channel\s/
      $' =~ /\d+/ 
      current = $&
    end
  end
  return freq_table, current
end


class WiFiScanner

  attr_reader :bssid

  def initialize
    @bssid = Hash.new
  end
  
  def clear
    @bssid.clear
  end

  def scan(iface = "wlan0")
    time = Time.now
    scan = IO.popen("iwlist #{iface} scan")
    parse_scanning(scan, time)
  end

  
  #TODO: What if a BSSID has changed (essid, channel, enc) since last scan?
  def parse_scanning(input, time = Time.now)
    bssid_info = OpenStruct.new
    bssid = "nil"                       # First time we save a nil entry.
    while line = input.gets
      if line =~ /Address:\s/
        bssid_info.time = time
        @bssid[bssid] = bssid_info.dup  # Save previous bssid info.
        bssid = $'.chop                 # Set current bssid.
      elsif line =~ /ESSID:\"/
        bssid_info.essid = $'.chop.chop
        next
      elsif line =~ /Protocol:IEEE\s/
        bssid_info.protocol = $'.chop
        next
      elsif line =~ /Mode:/
        bssid_info.mode = $'.chop
        next
      elsif line =~ /Frequency:/
        $' =~ /\d+\.\d+/
        bssid_info.freq = $&
        $' =~ /Channel\s/
        bssid_info.channel = $'.chop.chop
        next
        #elsif ( line =~ /Bit Rates:/) 
        #elsif ( line =~ /Encryption\skey:/)
        #elsif ( line =~ /Bit\sRates:/)
      elsif line =~ /Quality=/
        $' =~ /\d+/
        bssid_info.quality = $&
        next
      end

      #bssid_info.enc = # OPN, WEP, WPA, WPA2
      #bssid_info.ciper = # CCMP, WEP, TKIP
      #bssid_info.auth = # PSK, nil...

    end
    bssid_info.time = time
    @bssid[bssid] = bssid_info.dup # Save the last Cell found.
    @bssid.delete("nil")           # Remove the 'nil' entry.
  end

  def list_bssids
    list = []
    @bssid.each_key { |k| list.push(k)}
    return list
  end

  def has?(bssid)
    return @bssid[bssid] != nil
  end

  def save(fname)
  end

  
  def p
    @bssid.each { |k,v| print k; print " ";  puts v }
  end
end

s = WiFiScanner.new
s.scan("wlan0")
s.p
puts query_channels("wlan0")[1]
