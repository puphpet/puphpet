# Class: git
#
# This module manages git
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#

# This file is part of the git Puppet module.
#
#     The git Puppet module is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     The git Puppet module is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with the git Puppet module.  If not, see <http://www.gnu.org/licenses/>.

# [Remember: No empty lines between comments and class definition]
# NeSI git module
#
# Somewhat derived from https://github.com/theforeman/puppet-git
class git(
  $gui = false,
  $svn = true
){
  case $::operatingsystem  {
    CentOS,Ubuntu, Debian,Amazon:{
      class{'git::install':
        gui   => $gui,
        svn   => $svn,
      }
    }
    default:{
      warning("git is not configured for $::operatingsystem on $::fqdn")
    }
  }
}
