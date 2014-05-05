require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

describe user('rogue') do
  it { should exist }
  it { should belong_to_group 'sudo' }
  it { should belong_to_group 'rogue' }
  it { should belong_to_group 'roguecat' }
  it { should have_home_directory '/home/rogue' }
  it { should have_login_shell '/bin/bash' }
end

describe user('unison') do
  it { should exist }
  it { should have_home_directory '/home/unison' }
  it { should belong_to_group 'roguecat' }
  it { should have_login_shell '/bin/bash' }
end

describe group('roguecat') do
  it { should exist }
end