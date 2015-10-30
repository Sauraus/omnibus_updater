require_relative '../../../kitchen/data/spec_helper'

describe command('chef-client --version') do
  its(:stdout) { should contain('12.4.0') }
end
