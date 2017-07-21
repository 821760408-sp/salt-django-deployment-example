include:
  - circus
  - deploy

app-pkgs:
  pkg.installed:
    - pkgs:
      - git
{% if grains['os_family'] == 'Debian' %}
      - python-dev
      - sqlite3
      - libsqlite3-dev
{% elif grains['os_family'] == 'RedHat' %}
      - python-devel
      - sqlite
      - sqlite-devel
{% endif %}
      - python-virtualenv

webapp:
  git.latest:
    - name: {{ pillar['git_repo'] }}
    - rev: {{ pillar['git_rev'] }}
    - target: /var/www/myapp/
    - force_clone: true
    - require:
      - pkg: app-pkgs
      - file: deploykey
      - file: publickey
      - file: ssh_config

settings:
  file.managed:
    - name: /var/www/myapp/toydjangosite/settings.py
    - source: salt://webserver/settings.py
    - template: jinja
    - watch:
      - git: webapp

/var/www/env:
  virtualenv.manage:
    - requirements: /var/www/myapp/requirements.txt
    - system_site_packages: False
    - clear: False
    - require:
      - pkg: app-pkgs
      - file: settings
    - require_in:
      - service: start_circus

nginx:
  pkg:
    - latest
{% if grains['os_family'] == 'RedHat' %}
  file:
    - managed
    - name: /etc/nginx/nginx.conf
    - source: salt://webserver/nginx-redhat.conf
    - template: jinja
    - mode: 644
{% endif %}
  service:
    - running
    - watch:
      - file: nginxconf

nginxconf:
  file.managed:
    - name: /etc/nginx/sites-enabled/default
    - source: salt://webserver/nginx.conf
    - template: jinja
    - makedirs: True
    - mode: 755

gunicorn_circus:
    file.managed:
        - name: /etc/circus.d/gunicorn.ini
        - source: salt://webserver/gunicorn.ini
        - makedirs: True
        - watch_in:
            - service: start_circus
