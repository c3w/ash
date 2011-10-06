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
      if key == "type"
        $type = "#{value}"
      end
      if key == "port"
        $port = "-p #{value} "
      end
      if key == "tunnel_port"
	$tunnel_port = "-p #{value} "
      end
      if key == "tunnel_user"
	$tunnel_user = "-l #{value} "
      end
      if key == "tunnel"
        $tunnel = "-t #{value} "
      end
      if key == "fqdn"
        $fqdn = "#{value} "
      end
      if key == "user"
        $user = "-l #{value} "
      end
    end

    cmd = "echo 'tell app \"Terminal\" to set current settings of first window to settings set \"#{$type}\"' | osascript"
    system(cmd)

    if $tunnel != ""
      cmd = "ssh #{$tunnel} #{$tunnel_user} #{$tunnel_port} \"ssh #{$port} -t #{$fqdn} #{$user}\""
    else
      cmd = "ssh #{$port} #{$user} #{$fqdn}"
    end
    system(cmd)
end

cmd = "echo 'tell app \"Terminal\" to set current settings of first window to settings set \"#{$default_profile}\"' | osascript"
    system(cmd)
