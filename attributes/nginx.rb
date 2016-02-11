node.normal.nginx.version = '1.9.7'
node.normal.nginx.source.version = node.nginx.version
node.normal.nginx.source.url = "http://nginx.org/download/nginx-#{node.nginx.source.version}.tar.gz"

default['nginx']['default_site_enabled'] = false
default['nginx']['init_style'] = "init"
default['nginx']['webdir'] = "/var/www"
default['nginx']['install_method'] = 'source'
default['nginx']['source']['checksum'] = '794bd217affdfce1c6263d9199c3961f387a2df9d57dcb42876faaf41c1748d5'
default['nginx']['proxy']['buffer_size'] = '128k'
default['nginx']['proxy']['connect_timeout'] = 180
default['nginx']['proxy']['send_timeout'] = 180
default['nginx']['proxy']['read_timeout'] = 180
default['nginx']['proxy']['buffers'] = '32 4k'
default['nginx']['ssl']['session_cache_timeout'] = '50m'
default['nginx']['ssl']['session_timeout'] = "5m"
default['nginx']['ssl']['protocols'] = "TLSv1 TLSv1.1 TLSv1.2"
default['nginx']['ssl']['ciphers'] = "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!3DES:!RC4:!MD5:!PSK"
default['nginx']['ssl']['ttl'] = 31536000

# Set sendfile to off when in development mode.
# http://smotko.si/nginx-static-file-problem/
if node['rogue']['debug']
  node.set['nginx']['sendfile'] = 'off'
end
