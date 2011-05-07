#
# Author: Yasuhito Takamiya <yasuhito@gmail.com>
#
# Copyright (C) 2008-2011 NEC Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#


When /^I try to run "([^"]*)"$/ do | command |
  if / > /=~ command
    # redirected
    run command
  else
    @log = `mktemp`.chomp
    run "#{ command } > #{ @log }"
  end
end


When /^I try to run "([^"]*)" \(log = "([^"]*)"\)$/ do | command, log_name |
  log = File.join( Trema.log_directory, log_name )
  run "#{ command } > #{ log }"
end


When /^I try trema run "([^"]*)" with following configuration \((.*)\):$/ do | args, options, config |
  verbose = if /verbose/=~ options
              "--verbose"
            else
              ""
            end

  trema_run = Proc.new do
    Tempfile.open( "trema.conf" ) do | f |
      f.puts config
      f.flush
      @trema_log = `mktemp`.chomp
      run "./trema run \"#{ args }\" -c #{ f.path } #{ verbose } > #{ @trema_log } 2>&1"
    end
  end

  if /background/=~ options
    Thread.start do
      trema_run.call
    end
  else
    trema_run.call
  end
end


When /^I try trema run "([^"]*)" with following configuration:$/ do | args, config |
  When "I try trema run \"#{ args }\" with following configuration (no options):", config
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End: