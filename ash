#!/usr/bin/env ruby

require 'json'

begin
  ashrc = "./.ashrc"
  f = File.open(ashrc, 'r')
rescue
  ashrc = ENV['HOME'] + "/.ashrc"
  f = File.open(ashrc, 'r')
end


begin
  if sshrc = File.exist?("./.ssh/id_dsa")
    sshrc = "./.ssh/id_dsa"
    postCmd = ""
  elsif sshrcTest = File.exist?("./.ssh/id_dsa.gpg")
    sshrc = "./.ssh/id_dsa.gpg"
    sshrcPlain=sshrc.gsub(".gpg", "")
    cmd = "gpg -o #{sshrcPlain} -d #{sshrc} >/dev/null 2>&1 && chmod og-rwx #{sshrcPlain}"
    system(cmd)
    sshrc = sshrcPlain
    postCmd = "rm -f #{sshrc}"
  else
    sshrc = ENV['HOME'] + "/.ssh/id_dsa"
    postCmd = ""
end

$tunnel = ""
host = ARGV[0]
$default_profile = "Pro"

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
      cmd = "ssh -i #{sshrc} -A #{$tunnel} #{$tunnel_user} #{$tunnel_port} \"#{$screen} ssh #{$port} -t #{$fqdn} #{$user}\""
    else
      sshrcPlain=sshrc.gsub(".gpg", "")
      cmd = "ssh -i #{sshrc} -A #{$port} #{$user} #{$fqdn} -t #{$screen}"
    end
    system(cmd)
    system(postCmd)
end

cmd = "echo 'tell app \"Terminal\" to set current settings of first window to settings set \"#{$default_profile}\"' | osascript"
    system(cmd)

end
