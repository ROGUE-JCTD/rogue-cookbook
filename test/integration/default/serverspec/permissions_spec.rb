require 'serverspec'


describe user('rogue') do
  it { should exist }
  it { should belong_to_group 'sudo' }
  it { should belong_to_group 'rogue' }
  it { should belong_to_group 'tomcat7' }
  it { should have_home_directory '/home/rogue' }
  it { should have_login_shell '/bin/bash' }
end

describe user('unison') do
  it { should exist }
  it { should have_home_directory '/home/unison' }
  it { should belong_to_group 'tomcat7' }
  it { should have_login_shell '/bin/bash' }
end

describe user('www-data') do
  it { should exist }
  it { should_not belong_to_group 'sudo' }
  it { should belong_to_group 'www-data' }
  it { should have_home_directory '/var/www' }
  it { should have_login_shell '/bin/false' }
end

