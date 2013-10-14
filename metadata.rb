name             'rogue-cookbook'
description      'Installs/Configures the ROGUE JCTD project'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "nginx"
depends "java"
depends "tomcat"
depends "hostsfile"