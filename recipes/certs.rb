
openssl_x509 node['cert']['certificate'] do
  common_name node['cert']['name']
  org node['cert']['org']
  org_unit node['cert']['org_unit']
  country node['cert']['country']
  key_file node['cert']['key']
  expire 3560
  only_if { node['create_self_signed_cert'] }
  owner 'www-data'
  group 'rogue'
end

if node['create_self_signed_cert'] and !node['certs'].include? node['cert']
  node.normal['certs'] = node['certs'] + [node['cert']['certificate']]
end

node['certs'].each do |cert|
  basename = File.basename cert

  link File.join "/usr/local/share/ca-certificates/#{basename}.crt" do
    to cert
    notifies :run, "execute[update_cacerts]", :immediately
  end

  execute "update_cacerts" do
    command "update-ca-certificates"
    action :nothing
  end

  execute "add cert to python" do
    command "cat #{cert} >> #{node['rogue']['geonode']['location']}local/lib/python2.7/site-packages/httplib2/cacerts.txt"
    not_if <<-EOH
      awk '
      # read A, the supposed subset file
      FNR == NR {a[$0]; next}
      # process file B
      $0 in a {delete a[$0]}
      END {if (length(a) == 0) {exit 0} else {exit 1}}' #{cert} #{node['rogue']['geonode']['location']}local/lib/python2.7/site-packages/httplib2/cacerts.txt
    EOH
  end

  execute "import #{basename} cert" do
    command "keytool -import -trustcacerts -alias #{basename} -file #{cert} -keystore #{node['java']['keystore']} -storepass #{node['java']['keystore_password']} -noprompt"
    only_if { File.exists?("#{node['java']['keystore']}") }
    not_if "keytool -list -keystore #{node['java']['keystore']} -storepass #{node['java']['keystore_password']} -alias #{basename}"
  end

end







