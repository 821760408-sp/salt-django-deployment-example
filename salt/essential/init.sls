# Install essential packages
essential:
  pkg.installed:
{% if grains['os_family'] == 'Debian' %}
    - pkgs:
      - build-essential
      - python-pip
{% elif grains['os_family'] == 'RedHat' %}
    - pkgs:
      - gcc
      - gcc-c++
      - make
      - openssl-devel
      - python2-pip
{% endif %}