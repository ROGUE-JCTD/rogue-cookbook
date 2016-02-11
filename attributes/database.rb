node.normal.postgresql.enable_pgdg_apt = true
node.normal.postgresql.version = "9.4"
node.normal.postgresql.client.packages = ["postgresql-client-#{node.postgresql.version}", "libpq-dev"]
