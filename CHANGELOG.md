Change Log
==========
All notable changes to this project will be documented in this file.

[Unreleased][unreleased]
------------------------
- Disable gzip compression in Geoserver (needed because of a known GeoGIG bug).
- Add `NOTIFICATION_LOCK_LOCATION` variable to the `local_settings.py` template.
- Deny access to routes with un-used script extension in Nginx (asp[x], php, jsp, cgi, and pl).
- Support for running in SSL.
- Add security headers to prevent clickjacking and XSS in the default nginx configuration.
- Disable the default nginx site configuration by default.
- Fix bug where the BROKER_URL was not being populated in update_templates.
- Parameterize the CONN_MAX_AGE Django DB setting.

[1.2] - 2015-01-20
------------------
- Bump the Geoshape version to release-1.2.
- Override the GeoNode help to go to the GeoSHAPE documentation.
- Adds CHANGELOG.md.

[1.1] - 2015-01-19
------------------
- Bumps the Nginx version to 1.4.4.
- Parameterizes the Nginx client_max_body_size variable and defaults it to 150mb.
- Adds a Celery configuration and RabbitMQ to the build.
- Renames GeoGit to GeoGIG and brings in latest changes. 
- Updates build to support installing GeoNode > 2.0.
- Updates build to use Geoserver 2.6-SNAPSHOT.

[1.0] - 2015-01-15
------------------
- Initial ROGUE release re-released using 1.0 tag.


[unreleased]: https://github.com/ROGUE-JCTD/rogue-cookbook/compare/release-1.2...HEAD
[1.2]: https://github.com/ROGUE-JCTD/rogue-cookbook/compare/release-1.1...release-1.2
[1.1]: https://github.com/ROGUE-JCTD/rogue-cookbook/compare/release-1.0...release-1.1
[1.0]: https://github.com/ROGUE-JCTD/rogue-cookbook/tree/release-1.0
