include:
  - openstack.mysql
  - openstack.repo

keystone-pkg:
  pkg:
    - name: keystone
    - installed
    - fromreo: private-openstack-repo
    - require:
      - service.running: mysql
      - mysql_database.present: keystone
      - mysql_grants.present: keystone
      - mysql_user.present: keystone
      - cmd.run: keystone-grant-wildcard
      - cmd.run: keystone-grant-localhost
      - cmd.run: keystone-grant-star
  service:
    - name: keystone
    - running
    - enable: True
    - restart: True
    - require:
      - service.running: mysql
    - watch:
      - file: /etc/keystone


keystone-setup:
  cmd.run:
    - unless: test -f /etc/setup-done-keystone
    - name: /root/scripts/keystone-setup.sh
    - require:
      - service.running: mysql
      - pkg.installed: keystone
      - file.recurse: /etc/keystone
      - file.recurse: /root/scripts
      - service.restart: keystone


/etc/keystone:
  file:
    - recurse
    - source: salt://openstack/keystone
    - template: jinja
    - watch:
      - pkg.installed: keystone
    - defaults:
        openstack_internal_address: {{ pillar['openstack']['openstack_internal_address'] }}
        openstack_public_address: {{ pillar['openstack']['openstack_public_address'] }}
        admin_password: {{ pillar['openstack']['admin_password'] }}
        service_password: {{ pillar['openstack']['service_password']}}
        service_token: {{ pillar['openstack']['admin_token'] }}
        admin_token: {{ pillar['openstack']['admin_token'] }}
        database_password: {{ pillar['openstack']['database_password'] }}
        database_host: {{ pillar['openstack']['database_host'] }}

#keystone-setup:
#  cmd.run:
#    - name: keystone-manage --config-file /etc/keystone/keystone.conf db_sync
#    - require:
#      - pkg.installed: keystone
#      - mysql_database.present: keystone
#      - cmd.run: keystone-grant
#    - watch:
#      - file: /etc/keystone
#
#keystone-basic:
#  cmd.run:
#    - name: /root/scripts/keystone_basic.sh
#    - require:
#      - file: /etc/keystone
#      - pkg.installed: keystone
#      - mysql_database.present: keystone
#      - cmd.run: keystone-grant
#      - cmd.run: keystone-setup
#
#keystone-endpoints:
#  cmd.run:
#    - name: /root/scripts/keystone_endpoints_basic.sh
#    - require:
#      - file: /etc/keystone
#      - pkg.installed: keystone
#      - mysql_database.present: keystone
#      - cmd.run: keystone-grant
#      - cmd.run: keystone-setup
#      - cmd.run: keystone-basic

#keystone-setup:
#  cmd.script:
#    - unless: test -f /etc/setup-done-keystone
#    - name: salt://openstack/scripts/keystone-setup.sh
#    - require:
#      - service.running: mysql
#      - pkg.installed: keystone
#      - file: /etc/keystone
#      - service.restart: keystone
#    - context:
#      - openstack: {{ pillar['openstack'] }}
