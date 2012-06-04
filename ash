#!/usr/bin/env ruby

require 'json'

ashrc = ENV['HOME'] + "/.ashrc"
$tunnel = ""
host = ARGV[0]
$default_profile = "Pro"

f = File.open(ashrc, 'r')
json = f.read
hash = JSON.parse(json)


stuff = hash.select{|key, hash| key == host}

stuff.each do|k,v|
    v.each do|key, value|
      case key
        when "fqdn"
          $fqdn = "#{value} "
        when "type"
          $type = "#{value}"
        when "port"
          $port = "-p #{value} "
        when "user"
          $user = "-l #{value} "
        when "tunnel"
          $tunnel = "-t #{value} "
        when "tunnel_port"
	  $tunnel_port = "-p #{value} "
        when "tunnel_user"
	  $tunnel_user = "-l #{value} "
        when "screen"
	  $screen = "screen -x -r #{value} "
      end
    end

    cmd = "echo 'tell app \"Terminal\" to set current settings of first window to settings set \"#{$type}\"' | osascript"
    system(cmd)

    if $tunnel != ""
      cmd = "ssh -A #{$tunnel} #{$tunnel_user} #{$tunnel_port} \"#{$screen} ssh #{$port} -t #{$fqdn} #{$user}\""
    else
      cmd = "ssh -A #{$port} #{$user} #{$fqdn} -t #{$screen}"
    end
    system(cmd)
end

cmd = "echo 'tell app \"Terminal\" to set current settings of first window to settings set \"#{$default_profile}\"' | osascript"
    system(cmd)
