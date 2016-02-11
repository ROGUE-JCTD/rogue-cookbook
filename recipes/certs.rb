if node['create_self_signed_cert']
  openssl_x509 node['cert']['certificate'] do
    common_name node['cert']['name']
    org node['cert']['org']
    org_unit node['cert']['org_unit']
    country node['cert']['country']
    key_file node['cert']['key']
    expire 3560
    only_if { node['create_self_signed_cert'] }
    not_if "test -f #{node['cert']['certificate']}"
    owner node.nginx.user
    group 'rogue'
  end

  node.normal['certs'] = node['certs'] + [node['cert']['certificate']] if !node['certs'].include? node['cert']
  cacerts = "#{node.rogue.geonode.location}local/lib/python2.7/site-packages/httplib2/cacerts.txt"

  node['certs'].each do |cert|
    basename = File.basename cert

    link "/usr/local/share/ca-certificates/#{basename}.crt" do
      to cert
      notifies :run, "execute[update-ca-certificates]", :immediately
    end

    execute "update-ca-certificates" do
      action :nothing
    end

    execute "cat #{cert} >> #{cacerts}" do
      not_if {IO.read(cacerts).include?(IO.read(cert))}
      only_if "test -f #{cacerts}"
    end

    # file cacerts do
      # content "#{IO.read(cacerts)}\n#{IO.read(cert)}"
      # not_if {IO.read(cacerts).include?(IO.read(cert))}
    # end

    execute "import #{basename} cert" do
      command "keytool -import -trustcacerts -alias #{basename} -file #{cert} -keystore #{node['java']['keystore']} -storepass #{node['java']['keystore_password']} -noprompt"
      only_if { File.exists?("#{node['java']['keystore']}") }
      not_if "keytool -list -keystore #{node['java']['keystore']} -storepass #{node['java']['keystore_password']} -alias #{basename}"
    end
  end
end
