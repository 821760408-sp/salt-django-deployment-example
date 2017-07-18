{% from "circus/map.jinja" import circus with context %}

include:
  - essential

install_circus:
  pip.installed:
    - name: {{ circus.pkg }}

circus_systemd:
  file.managed:
    - name: {{ circus.systemdtarget }}
    - source: {{ circus.systemdsource }}
    - makedirs: True

circus_conf:
  file.managed:
    - name: {{ circus.configtarget }}
    - source: {{ circus.configsource }}

circus_dir:
  file.directory:
    - name: {{ circus.circusdir }}

start_circus:
  service.running:
    - name: {{ circus.service }}
    - require:
      - file: circus_systemd
      - file: circus_dir