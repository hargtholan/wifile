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

require 'ostruct'

# require 'oui'
# require 'wifiscanner'
#

DEFAULT_ADMINAUTH = {
  "Zyxel" =>["admin","admin"]
  "Belkin" =>["admin","1234"]
  "Thomson" =>["1234","1234"]
  "" =>["","admin"]
}

# Encription systems:
#
# TELEFONICA_WEP: WLAN_5C, WLAN_4C...
# JAZZTEL_WPA: JAZZTEL_1C49, JAZZTEL_56F1...
# TELEFONICA_WPA: WLAN_2B42, WLAN_612D...
#
#

#This class should contain a history of all wifi networks.

class WIFINetworkManager

  def initialize
    @scanner = WiFiScanner.new

    @ap = Hash.new #Table of all known APs.

    @ap_info.model = ""
    @ap_info.enckey = ""
    @ap_info.dhcp = false
    @ap_info.ip = ""
    @ap_info.adminuser = ""
    @ap_info.adminpass = ""
    @ap_info.clients = [] #List of know clients MAC addresses.

  end

  def scan(iface)
    @scanner.scan(iface)
  end

  def connect(iface, bssid)
  end

  def disconnect(iface)
  end

  def generte_config(bssid)
  end

  def has_dhcpd?(bssid)
  end

  def guess_cracking_method(bssid)
  end

  def crack(bssid)
  end

  def default_adminpass # 1234/1234, admin/1234, and so on...
    return user, password
  end

  def load(fname)
  end

  def save(fname)
  end

end
