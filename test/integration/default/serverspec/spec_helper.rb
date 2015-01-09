require 'serverspec'
require 'pathname'

set :backend, :exec
set :path, "/opt/chef/embedded/bin:/sbin:/usr/local/sbin:$PATH"
