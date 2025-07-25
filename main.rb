#!/usr/bin/env ruby

require 'readline'
require 'socket'
require 'rbconfig'

$evanense_started_tor = false

# List of network-based commands to route through Tor

NETWORK_CMDS = %w[
  curl wget httpie nikto whatweb wafw00f whois dig host nslookup
  theHarvester amass sublist3r dnsenum nmap msfconsole
  ffuf gobuster dirb dirbuster
  ssh telnet ftp smbclient nc
  hydra enum4linux zmap masscan rustscan
]




def start_tor_cross_platform
  os = RbConfig::CONFIG['host_os']

  puts "[*] Attempting to start Tor..."

  if os =~ /linux/
    success = system("systemctl start tor") || system("service tor start") || system("tor &")
  elsif os =~ /darwin/
    success = system("tor &")  # macOS — assuming Tor is installed via brew
  else
    puts "[!] Unsupported OS: #{os}"
    return false
  end
  
 $evanense_started_tor = true if success

  unless success
    puts "[!] Failed to start Tor on #{os}"
    return false
  end

  true
end

# Check if Tor is running (SOCKS port)
def tor_running?
  begin
    TCPSocket.new("127.0.0.1", 9050).close
    true
  rescue
    false
  end
end

# Start Tor service or daemon
def start_tor
  puts "[*] Checking for Tor..."
  unless tor_running?
    puts "[*] Tor is not running. Attempting to start..."

    unless start_tor_cross_platform
      puts "[!] Could not start Tor."
      exit(1)
    end

    print "[*] Waiting for Tor to bootstrap"
    20.times do
      sleep 1
      print "."
      if tor_running?
        puts "\n[+] Tor is running!"
        return
      end
    end

    puts "\n[!] Tor did not respond after 20 seconds."
    exit(1)
  else
    puts "[+] Tor is already running."
  end
end



# Request new Tor identity (circuit)
def new_tor_circuit
   if `which nc`.empty?
    puts "[!] Netcat (nc) not installed. Cannot request new circuit."
    return
  end

  puts "[*] Requesting a new Tor circuit..."
  system('echo -e "AUTHENTICATE\nSIGNAL NEWNYM\nQUIT" | nc 127.0.0.1 9051')
end


# Stopping tor 
def stop_tor_cross_platform
  os = RbConfig::CONFIG['host_os']

  puts "[*] Stopping Tor..."

  case os
  when /linux/
    system("sudo systemctl stop tor") || system("sudo service tor stop") || system("sudo pkill tor")
  when /darwin/
    # On macOS: assumes tor installed via Homebrew, and run as user
    system("pkill tor") || puts("[!] Could not stop Tor on macOS — try 'killall tor'")
  else
    puts "[!] Unsupported OS: #{os}"
  end
end


start_tor
puts "[*] Evanense → Tor-enabled Pentest Shell"
puts "[*] Type 'help' to check for available commands"

# Tab completion
Readline.completion_proc = proc do |s|
  Dir.glob("#{s}*") + Readline::HISTORY.grep(/^#{Regexp.escape(s)}/)
end

# Main shell loop
while input = Readline.readline('> ', true)
  break if input.nil?  # Ctrl+D
  input.strip!
  next if input.empty?

  case input.downcase
  when "exit"
    break
  when "clear"
    system("clear")
    next
  when "hist"
    puts Readline::HISTORY.to_a
    next
  when "torip"
      puts "[*] Checking current Tor IP..."
      system("torsocks curl -s https://check.torproject.org | grep -Eo 'Your IP address appears to be:.*' || echo '[!] Failed to fetch Tor IP.'")
  next
  
  when "update"
  puts "[*] Checking for updates..."
  if File.directory?(".git")
    output = `git pull`
    if output.include?("Already up to date")
      puts "[*] No updates found."
    else
      puts "[+] Update complete!\n#{output}"
    end
  else
    puts "[!] Not a Git repository. Cannot check for updates."
  end
  next

  when "help"
    puts <<~HELP

      Evanense — Tor-enabled Pentest Shell

      Internal commands:
        exit     : Exit the shell
        clear    : Clear the screen
        hist     : Show command history
        update   : Pull latest updates from Git
        nis      : Request a new Tor circuit (new IP)
        help     : Show this help menu
        torip    : Show current Tor IP address

      External commands may also route through tor if properly configured:
        #{NETWORK_CMDS.join(', ')}

    HELP
    next
  when "nis"
    new_tor_circuit
    next
  end

  base_cmd = input.split.first

  if NETWORK_CMDS.include?(base_cmd)
    torsocks_cmd = "torsocks #{input}"
    proxychains_cmd = "proxychains #{input}"

    puts "[+] Routing via Tor: #{torsocks_cmd}"
    torsocks_success = system(torsocks_cmd)

    unless torsocks_success
      puts "[!] Torsocks failed. Trying fallback: #{proxychains_cmd}"
      proxychains_success = system(proxychains_cmd)

      unless proxychains_success
        puts "[x] Both torsocks and proxychains failed."
      end
    end
  else
    system(input)
  end
end

puts "[*] Exiting Evanense."



if $evanense_started_tor
  stop_tor_cross_platform
end


