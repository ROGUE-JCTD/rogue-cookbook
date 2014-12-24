postgresql_connection_info = {
  :host     => node['rogue']['networking']['database']['hostname'],
  :port     => node['rogue']['postgresql']['port'],
  :username => node['rogue']['postgresql']['user'],
  :password => node['rogue']['postgresql']['password']
}

gem_package "pg" do
  action :install
  not_if {File.exist?("/opt/chef")}
end

geonode_connection_info = node['rogue']['rogue_geonode']['settings']['DATABASES']['default']
geonode_imports_connection_info = node['rogue']['rogue_geonode']['settings']['DATABASES']['geonode_imports']

# Create the GeoNode user
postgresql_database_user geonode_connection_info[:user] do
  connection postgresql_connection_info
  password geonode_connection_info[:password]
  action :create
end

# Grant Postgres privileges to geonode.  Necessary for AWS RDS.
bash 'grant privileges' do
  code <<-EOH
  PGPASSWORD='#{postgresql_connection_info[:password]}' psql --host='#{postgresql_connection_info[:host]}' --port=5432 --username postgres -c "GRANT geonode to postgres;"
  EOH
  only_if { node['rogue']['aws_rds'] }
end

# Create the GeoNode database
postgresql_database geonode_connection_info[:name] do
  connection postgresql_connection_info
  owner geonode_connection_info[:user]
  encoding 'UTF8'
  collation 'en_US.utf8'
  template 'template0'
  action :create
end

# Create the GeoNode imports user
postgresql_database_user geonode_imports_connection_info[:user] do
  connection postgresql_connection_info
  password geonode_imports_connection_info[:password]
  action :create
end

# Create the GeoNode imports db
postgresql_database geonode_imports_connection_info[:name] do
  connection postgresql_connection_info
  template node.fetch('postgis', {}).fetch('template_name', 'template_postgis')
  owner geonode_imports_connection_info[:user]
  action :create
end

postgresql_database 'set user' do
  connection   postgresql_connection_info
  database_name geonode_imports_connection_info[:name]
  sql 'grant select on geometry_columns, spatial_ref_sys to ' + geonode_imports_connection_info[:user] + ';'
  action :query
end

postgresql_database 'add_geonode_authorize_layer_function' do
  connection   postgresql_connection_info
  database_name geonode_connection_info[:name]
  sql <<-EOH
CREATE OR REPLACE FUNCTION geonode_authorize_layer(user_name varchar, type_name varchar) RETURNS varchar AS $$

DECLARE
view_perm integer;
change_perm integer;
manage_perm integer;
roles varchar[] = '{anonymous,NULL}';
ct integer;
user RECORD;
layer RECORD;
group_ids integer[];
BEGIN

-- get the layer and user, take quick action if we can
SELECT INTO layer "base_resourcebase"."id", "base_resourcebase"."owner_id"
FROM "base_resourcebase", "layers_layer"
WHERE "base_resourcebase"."id" = "layers_layer"."resourcebase_ptr_id" AND "layers_layer"."typename" = type_name;
if (not FOUND) then
	-- no layer
	return 'nl';
end if;
if (user_name IS NOT NULL) then
	SELECT INTO user * FROM "people_profile" WHERE "people_profile"."username" = user_name;
	if (not FOUND) then
		-- no user
		return 'nu';
	end if;


	if ("user".id = "layer".owner_id) then
		-- layer owner
		return 'lo-rw';
	end if;
	if ("user".is_superuser) then
		-- super user
		return 'su-rw';
	end if;
	roles[2] = 'authenticated';
end if;

-- resolve permission and content_type ids
SELECT INTO view_perm "auth_permission"."id"
  FROM "auth_permission" INNER JOIN "django_content_type"
  ON ("auth_permission"."content_type_id" = "django_content_type"."id")
  WHERE ("auth_permission"."codename" = E'view_resourcebase'
  AND "django_content_type"."app_label" = E'base' );

SELECT INTO change_perm "auth_permission"."id"
	FROM "auth_permission" INNER JOIN "django_content_type"
	ON ("auth_permission"."content_type_id" = "django_content_type"."id")
	WHERE ("auth_permission"."codename" = E'change_resourcebase'
	AND "django_content_type"."app_label" = E'base' );

SELECT INTO manage_perm "auth_permission"."id"
	FROM "auth_permission" INNER JOIN "django_content_type"
	ON ("auth_permission"."content_type_id" = "django_content_type"."id")
	WHERE ("auth_permission"."codename" = E'change_resourcebase_permissions'
	AND "django_content_type"."app_label" = E'base' );

SELECT INTO ct "django_content_type"."id"
	FROM "django_content_type"
	WHERE ("django_content_type"."model" = E'resourcebase'
	AND "django_content_type"."app_label" = E'base' );

SELECT INTO group_ids array_agg("groups_groupmember"."group_id")
  FROM "groups_groupmember"
  WHERE "groups_groupmember"."user_id" = "user".id;


--RAISE NOTICE 'View Perm: %', view_perm;
--RAISE NOTICE 'Change Perm: %', change_perm;
--RAISE NOTICE 'Content Type: %', ct;
--RAISE NOTICE 'User ID: %', "user".id;
--RAISE NOTICE 'Layer ID: %', "layer".id;
--RAISE NOTICE 'Group IDs: %', group_ids;

if (user_name IS NOT NULL) then
	-- user role, read-write
	PERFORM "guardian_userobjectpermission"."object_pk"
		FROM "guardian_userobjectpermission"
		INNER JOIN "auth_permission"
		ON ("guardian_userobjectpermission"."permission_id" = "auth_permission"."id")
		WHERE (("auth_permission"."id" = change_perm or "auth_permission"."id" = manage_perm)
		AND "guardian_userobjectpermission"."content_type_id" = ct
		AND ("guardian_userobjectpermission"."user_id" = "user".id or "guardian_userobjectpermission"."user_id" = -1)
		AND "guardian_userobjectpermission"."object_pk"::integer = "layer".id
		);
	if (FOUND) then return 'ur-rw'; end if;

  -- user role, user has read-write permissions via group membership
  PERFORM "guardian_groupobjectpermission"."object_pk"
		FROM "guardian_groupobjectpermission"
		INNER JOIN "auth_permission"
		ON ("guardian_groupobjectpermission"."permission_id" = "auth_permission"."id")
		WHERE (("auth_permission"."id" = change_perm or "auth_permission"."id" = manage_perm)
		AND "guardian_groupobjectpermission"."content_type_id" = ct
		AND "guardian_groupobjectpermission"."group_id" = ANY (group_ids)
		AND "guardian_groupobjectpermission"."object_pk"::integer = "layer".id
		);
	if (FOUND) then return 'group-rw'; end if;

	PERFORM "guardian_userobjectpermission"."object_pk"
		FROM "guardian_userobjectpermission"
		INNER JOIN "auth_permission"
		ON ("guardian_userobjectpermission"."permission_id" = "auth_permission"."id")
		WHERE ("auth_permission"."id" = view_perm
		AND "guardian_userobjectpermission"."content_type_id" = ct
		AND ("guardian_userobjectpermission"."user_id" = "user".id or "guardian_userobjectpermission"."user_id" = -1)
		AND "guardian_userobjectpermission"."object_pk"::integer = "layer".id
		);
	if (FOUND) then return 'ur-ro'; end if;

  -- user role, user has read-write permissions via group membership
  PERFORM "guardian_groupobjectpermission"."object_pk"
		FROM "guardian_groupobjectpermission"
		INNER JOIN "auth_permission"
		ON ("guardian_groupobjectpermission"."permission_id" = "auth_permission"."id")
		WHERE ("auth_permission"."id" = view_perm
		AND "guardian_groupobjectpermission"."content_type_id" = ct
		AND "guardian_groupobjectpermission"."group_id" = ANY (group_ids)
		AND "guardian_groupobjectpermission"."object_pk"::integer = "layer".id
		);
	if (FOUND) then return 'group-ro'; end if;



end if;

-- uh oh, nothing found
return 'nf';

END
$$ LANGUAGE plpgsql;
  EOH
  action :query
  only_if { node['rogue']['geoserver']['use_db_client'] }
end
