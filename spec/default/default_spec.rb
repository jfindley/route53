require 'spec_helper'

chef_run = ChefSpec::ServerRunner.new(:cookbook_path => ENV["COOKBOOK_PATH"].split(",")) if ENV.has_key?("COOKBOOK_PATH")

describe package('fog') do
  it { should be_installed.by('gem') }
end
