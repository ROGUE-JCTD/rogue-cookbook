template "/etc/default/celeryd" do
  source "celery/config.erb"
  mode 0644
  variables(
    :location => node['rogue']['geonode']['location']
  )
end

template "/etc/init.d/celeryd" do
  source "celery/init.erb"
  mode 0755
end

service "celeryd" do
  supports :start => true, :stop => true, :restart => true
  action :enable
end
