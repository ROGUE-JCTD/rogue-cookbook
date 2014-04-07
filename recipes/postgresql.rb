node.default['postgresql']['password']['postgres'] = 'rogue'
node.default['postgresql']['pg_hba'] = [
  {:type => 'local', :db => 'all', :user => 'postgres', :addr => nil, :method => 'ident'},
  {:type => 'local', :db => 'all', :user => 'all', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '192.168.10.1/32', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '127.0.0.1/32', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '::1/128', :method => 'md5'}
]

# Add the postgres dev server to the installation
node.default['postgresql']['server']['packages'] = ["postgresql-#{node['postgresql']['version']} postgresql-server-dev-#{node['postgresql']['version']}"]

include_recipe 'build-essential'
include_recipe 'postgresql::server'
include_recipe 'rogue::postgis'

gem_package "pg" do
  action :install
  not_if {File.exist?("/opt/chef")}
end


# Work around for https://tickets.opscode.com/browse/COOK-1406
# Only running when the /opt/chef directroy is present is used
# to detect omnibus installations.

bash "manually install postgres" do
  code <<-EOF
apt-get install -y build-essential
apt-get build-dep -y postgresql
wget http://ftp.postgresql.org/pub/source/v9.2.1/postgresql-9.2.1.tar.gz
tar -zxvf postgresql-9.2.1.tar.gz
cd postgresql-9.2.1
export MAJOR_VER=9.2
./configure \
  --prefix=/opt/chef/embedded \
  --mandir=/opt/chef/embedded/share/postgresql/${MAJOR_VER}/man \
  --docdir=/opt/chef/embedded/share/doc/postgresql-doc-${MAJOR_VER} \
  --sysconfdir=/etc/postgresql-common \
  --datarootdir=/opt/chef/embedded/share/ \
  --datadir=/opt/chef/embedded/share/postgresql/${MAJOR_VER} \
  --bindir=/opt/chef/embedded/lib/postgresql/${MAJOR_VER}/bin \
  --libdir=/opt/chef/embedded/lib/ \
  --libexecdir=/opt/chef/embedded/lib/postgresql/ \
  --includedir=/opt/chef/embedded/include/postgresql/ \
  --enable-nls \
  --enable-integer-datetimes \
  --enable-thread-safety \
  --enable-debug \
  --with-gnu-ld \
  --with-pgport=5432 \
  --with-openssl \
  --with-libedit-preferred \
  --with-includes=/opt/chef/embedded/include \
  --with-libs=/opt/chef/embedded/lib
make
sudo make install
sudo /opt/chef/embedded/bin/gem install pg -- --with-pg-config=/opt/chef/embedded/lib/postgresql/9.2/bin/pg_config
EOF
  only_if { File.exists?("/opt/chef") }
  not_if "/opt/chef/embedded/bin/gem list | grep pg"
end

