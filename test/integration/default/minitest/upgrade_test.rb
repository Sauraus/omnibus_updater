require 'minitest/autorun'

describe_recipe 'omnibus_updater::default' do

  it "sets remote package location" do
    assert(node[:omnibus_updater][:full_url], "Failed to set URI for omnibus package")
  end

  it "downloads the package to the node" do
    assert File.exists?("/opt/#{File.basename(node[:omnibus_updater][:full_url])}")
  end

  it "installs the proper version into the node" do
    assert_equal(
      node[:omnibus_updater][:version].scan(/^\d+\.\d+\.\d+/).first,
      `chef-client --version`.strip.scan(/\d+\.\d+\.\d+/).first,
      "Installed chef version does not match version requested"
    )
  end

end
