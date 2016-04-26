require_relative '../../../kitchen/data/spec_helper'

describe command('/usr/local/bin/chef-client --version') do
  its(:stdout) { should contain('12.6.0') }
end
