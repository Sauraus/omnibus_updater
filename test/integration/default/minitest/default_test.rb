require 'minitest/autorun'

describe_recipe 'omnibus_updater::downloader' do

  it "sets remote package location" do
    assert(node[:omnibus_updater][:full_url], "Failed to set URI for omnibus package")
  end

  it "does download the package to the node" do
    assert File.exists?(File.join(node[:omnibus_updater][:cache_dir], File.basename(remote_path)))
  end

end
