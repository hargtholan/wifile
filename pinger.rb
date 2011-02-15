#This file is part of Rpinger.
#
# Copyright (C) 2011 Juan V. Puertos Ahuir <juanvi.puertos@gmail.com>
#
#    Rpinger is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    Rpinger is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with Rpinger.  If not, see <http://www.gnu.org/licenses/>.


require 'io/wait'
require 'open3'

def bits2mbytes(speed)
  speed /= 8.0 # bits to bytes.
  if speed >= 1024 
    speed /= 1024 # bytes to kilo-bytes.
    if speed >= 1024
      speed /= 1024 # kilo-bytes to mega-bytes
      return "#{speed} MB/s"
    else
      return "#{speed} KB/s"
    end
  else
    return "#{speed} B/s"
  end
end

def tx_bps(interval, size)
  return (1.0 / interval) * (size + 8)
end


class Pinger
  attr_reader :history, :average, :max, :min, :dup, :lost, :wait, :command
  attr_writer :destination, :count, :size, :interval, :adaptative
  
  def initialize
    #Parameters
    @destination = "10.42.43.1"
    @adaptative = false
    @preload = false
    @count = 0
    @size = 58      # 'ping' default value.
    @interval = 1.0 # 'ping' default value.
    @deadline = 0.0
    
    @command = ""
    @ping_stdout
    @ping_stderr
    @thread

    #Updated in real time.
    @history = Array.new
    @total_time = 0.0
    @average = 0.0
    @max = Float::MIN
    @min = Float::MAX
    @var = 0.0
    @dup = 0
    @lost = 0
  end

  def GenerateCommand
    @command = "ping -s #{@size} -i #{@interval}"
    if @count != 0 then @command += " -c #{@count}" end
    if @addaptative then @command += " -A" end
    if @preload then @command += " -l" end
    if @deadline > 0.0 then @command += " -w #{@deadline}" end
    @command += " #{@destination}"
  end

  def Launch
    stdin, @ping_stdout, @ping_stdout, @therad = Open3.popen3(@command)
    @ping_pid = @thread.pid
    puts @ping_pid
#    @ping_stdout.wait
    puts @ping_stdout.read # Catches the first line spited by ping.
    puts @thread.value
  end
  
  def Update(timeout)
    p = select([@ping_stdout], [], [], timeout)
    if (p == nil)
      return false
    end
    
    line = @ping_stdout.gets
    puts line
    # ECHO_REPLY: Process stuff

    # ICMP_REQ
    line =~ /icmp_req=/
    $' =~ /\d+/
    icmp_req = $&.to_i
    
    # Check for DUPs, lost, or delayed replies
    if (@history.length > 0) # n-1 times... :(
      if ( icmp_req <= @history[-1][0] )
        if (line =~ /DUP/)
          @dup += 1
        else # If it is not a DUP, then it must be a delayed reply. Is this actually possible?
          @lost -= 1
        end
      elsif ( icmp_req > @history[-1][0]+1) # Count for lost packets.
        @lost += icmp_req-(@history[-1][0]+1)   
      end
    end
    
    # TIME
    line =~ /time=/
    $' =~ /\d+\.*\d+/
    time = $&.to_f
    
    @history.push([icmp_req, time]) # Shall we record if DUP, CORRUPTED and stuff like that?
    @total_time += time
    @average = @total_time / (@history.length)
    if ( time > @max ) then @max = time end
    if ( time < @min ) then @min = time end
    return true
  end
  
  def Clear
    @history.clear
    @total_time = 0.0
    @average = 0.0
    @max = Float::MIN
    @min = Float::MAX
    @var = 0.0
    @dup = 0
    @lost = 0
  end
  
  def SIGINT
    Process.kill("INT", @ping_pid)
    4.times { puts @ping_stdout.gets }
  end

  def QueryStatus
    Process.kill("QUIT", @ping_pid)
    4.times { puts @ping_stdout.gets }
  end
  
end


# This is just for testing, on-the-fly...
p = Pinger.new
p.GenerateCommand
puts p.command
p.Launch
10.times { p.Update(0.9) }
p.SIGINT
