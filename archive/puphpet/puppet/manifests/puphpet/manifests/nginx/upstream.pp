# This depends on jfryman/nginx: https://github.com/jfryman/puppet-nginx.git
# Creates a new upstream proxy entry
define puphpet::nginx::upstream (
  $fail_timeout = '10s',
  $members      = []
) {
  $count = count($members);
  notify{ "Adding nginx upstream for ${name} with ${count} members.":
    withpath => true
  }

  nginx::resource::upstream { $name:
    upstream_fail_timeout => $fail_timeout,
    members               => $members
  }
}
