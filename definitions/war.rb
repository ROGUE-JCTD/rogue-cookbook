require 'pathname'

define :war do
  name = params[:name]
  remote_file_location = params[:remote_file_location]
  tmp_dir = '/tmp'
  tomcat_web_dir = node['tomcat']['webapp_dir']

  log name
  log tmp_dir

  tmp_file = ::File.join(tmp_dir, name)
  base_file_name = Pathname.new(tmp_file)

  if params[:action] == :deploy
    remote_file tmp_file do
      source remote_file_location
      action :create
      retries 10
      retry_delay 1
    end

    service 'tomcat' do
      action :stop
    end

    execute "deploy_war" do
      command "mv #{tmp_file} #{tomcat_web_dir}"
      action :run
    end

    tomcat_folder = ::File.join(tomcat_web_dir, base_file_name.basename.to_s.sub(base_file_name.extname, ""))
    execute "remove_previous_dir" do
      command "rm -rf #{tomcat_folder}"
      only_if { File.exists? tomcat_folder }
    end

    execute "deploy_war" do
      command "mkdir #{tomcat_folder} && cd #{tomcat_folder} && jar -xvf ../#{base_file_name.basename} && cd .. && chown -R #{node['tomcat']['user']}:#{node['tomcat']['group']} #{tomcat_folder}"
      cwd node['tomcat']['webapp_dir']
    end

    service 'tomcat' do
      action :start
    end
  end
end