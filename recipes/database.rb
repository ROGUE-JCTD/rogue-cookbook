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

# Create the GeoNode database
postgresql_database geonode_connection_info[:name] do
  connection postgresql_connection_info
  owner geonode_connection_info[:user]
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
roles varchar[] = '{anonymous,NULL}';
ct integer;
user RECORD;
layer RECORD;
groups_enabled BOOLEAN;
BEGIN

-- see if groups are enabled
SELECT INTO groups_enabled EXISTS(SELECT *
            FROM information_schema.tables
            WHERE TABLE_NAME='groups_group');

-- get the layer and user, take quick action if we can
SELECT INTO layer "base_resourcebase"."id", "base_resourcebase"."owner_id"
FROM "base_resourcebase", "layers_layer"
WHERE "base_resourcebase"."id" = "layers_layer"."resourcebase_ptr_id" AND "layers_layer"."typename" = type_name;
if (not FOUND) then
	-- no layer
	return 'nl';
end if;
if (user_name IS NOT NULL) then
	SELECT INTO user * FROM "auth_user" WHERE "auth_user"."username" = user_name;
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
        WHERE ("auth_permission"."codename" = E'view_layer'
        AND "django_content_type"."app_label" = E'layers' );
SELECT INTO change_perm "auth_permission"."id"
	FROM "auth_permission" INNER JOIN "django_content_type"
	ON ("auth_permission"."content_type_id" = "django_content_type"."id")
	WHERE ("auth_permission"."codename" = E'change_layer'
	AND "django_content_type"."app_label" = E'layers' );
SELECT INTO ct "django_content_type"."id"
	FROM "django_content_type"
	WHERE ("django_content_type"."model" = E'layer'
	AND "django_content_type"."app_label" = E'layers' );


-- generic role, read-write
PERFORM "security_genericobjectrolemapping"."object_id"
	FROM "security_genericobjectrolemapping"
	INNER JOIN "security_objectrole"
	ON ("security_genericobjectrolemapping"."role_id" = "security_objectrole"."id")
	INNER JOIN "security_objectrole_permissions"
	ON ("security_objectrole"."id" = "security_objectrole_permissions"."objectrole_id")
	WHERE ("security_genericobjectrolemapping"."subject" = any(roles)
	AND "security_objectrole_permissions"."permission_id" = change_perm
	AND "security_genericobjectrolemapping"."object_ct_id" = ct
	AND "security_genericobjectrolemapping"."object_id" = layer.id
	);
if (FOUND) then return 'gr-rw'; end if;


if (user_name IS NOT NULL) then
	-- user role, read-write
	PERFORM "security_userobjectrolemapping"."object_id"
		FROM "security_userobjectrolemapping"
		INNER JOIN "security_objectrole"
		ON ("security_userobjectrolemapping"."role_id" = "security_objectrole"."id")
		INNER JOIN "security_objectrole_permissions"
		ON ("security_objectrole"."id" = "security_objectrole_permissions"."objectrole_id")
		WHERE ("security_objectrole_permissions"."permission_id" = change_perm
		AND "security_userobjectrolemapping"."object_ct_id" = ct
		AND "security_userobjectrolemapping"."user_id" = "user".id
		AND "security_userobjectrolemapping"."object_id" = "layer".id
		);
	if (FOUND) then return 'ur-rw'; end if;

    -- user role, user has read-write permissions via group membership
    if (groups_enabled) then
    	PERFORM "security_groupobjectrolemapping"."object_id"
    	FROM "security_groupobjectrolemapping"
    	INNER JOIN "security_objectrole"
        ON ("security_groupobjectrolemapping"."role_id" = "security_objectrole"."id")
        INNER JOIN "security_objectrole_permissions"
        ON ("security_objectrole"."id" = "security_objectrole_permissions"."objectrole_id")
        WHERE ("security_objectrole_permissions"."permission_id" = change_perm
        AND "security_groupobjectrolemapping"."object_ct_id" = ct
        AND "security_groupobjectrolemapping"."group_id" IN (SELECT DISTINCT(group_id) FROM groups_groupmember WHERE user_id="user".id)
        AND "security_groupobjectrolemapping"."object_id" = "layer".id
        );
    if (FOUND) then return 'group-rw'; end if;
    end if;

	-- user role, read-only
	PERFORM "security_userobjectrolemapping"."object_id"
		FROM "security_userobjectrolemapping"
		INNER JOIN "security_objectrole"
		ON ("security_userobjectrolemapping"."role_id" = "security_objectrole"."id")
		INNER JOIN "security_objectrole_permissions"
		ON ("security_objectrole"."id" = "security_objectrole_permissions"."objectrole_id")
		WHERE ("security_objectrole_permissions"."permission_id" = view_perm
		AND "security_userobjectrolemapping"."object_ct_id" = ct
		AND "security_userobjectrolemapping"."user_id" = "user".id
		AND "security_userobjectrolemapping"."object_id" = "layer".id
		);
	if (FOUND) then return 'ur-ro'; end if;

	-- user role, user has read-only permissions via group membership
	if (groups_enabled) then
    PERFORM "security_groupobjectrolemapping"."object_id"
      FROM "security_groupobjectrolemapping"
      INNER JOIN "security_objectrole"
      ON ("security_groupobjectrolemapping"."role_id" = "security_objectrole"."id")
      INNER JOIN "security_objectrole_permissions"
      ON ("security_objectrole"."id" = "security_objectrole_permissions"."objectrole_id")
      WHERE ("security_objectrole_permissions"."permission_id" = view_perm
      AND "security_groupobjectrolemapping"."object_ct_id" = ct
      AND "security_groupobjectrolemapping"."group_id" IN (SELECT DISTINCT(group_id) FROM groups_groupmember WHERE user_id="user".id)
      AND "security_groupobjectrolemapping"."object_id" = "layer".id
      );
	if (FOUND) then return 'group-ro'; end if;
	end if;
end if;

-- generic role, read-only
PERFORM "security_genericobjectrolemapping"."object_id"
	FROM "security_genericobjectrolemapping"
	INNER JOIN "security_objectrole"
	ON ("security_genericobjectrolemapping"."role_id" = "security_objectrole"."id")
	INNER JOIN "security_objectrole_permissions"
	ON ("security_objectrole"."id" = "security_objectrole_permissions"."objectrole_id")
	WHERE ("security_genericobjectrolemapping"."subject" = any(roles)
	AND "security_objectrole_permissions"."permission_id" = view_perm
	AND "security_genericobjectrolemapping"."object_ct_id" = ct
	AND "security_genericobjectrolemapping"."object_id" = layer.id
	);
if (FOUND) then return 'gr-ro'; end if;

-- uh oh, nothing found
return 'nf';

END
$$ LANGUAGE plpgsql;
  EOH
  action :query
  only_if { node['rogue']['geoserver']['use_db_client'] }
end
