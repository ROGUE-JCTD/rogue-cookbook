require 'serverspec'


describe command('java -version') do
  its(:stdout){ should include 'java version "1.7' }
end
