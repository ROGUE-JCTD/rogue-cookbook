require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

describe command('java -version') do
  its(:stdout){ should include 'java version "1.7' }
end
