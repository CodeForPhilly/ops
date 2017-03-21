{% set zpool_name = pillar['storage'].get('zpool_name', 'kubvols') %}

{% for container in pillar.get('storage', {}).get('containers', []) %}
  {% set container_name  = container['name'] %}
  {% set container_state = container.get('state', 'present') %}
zfs_dataset_{{ container_name }}:
  zfs.filesystem_{{ container_state }}:
    - name: {{ zpool_name }}/{{ container_name }}

  {% for vol in container.get('volumes', []) %}
    {% set vol_name  = vol['name']                              %}
    {% set vol_state = vol.get('state', 'present')              %}
    {% set vol_user  = vol.get('user')                          %}
    {% set vol_group = vol.get('group')                         %}
    {% set vol_mode  = vol.get('mode')                          %}
    {% set vol_props = vol.get('properties', {})                %}
    {% do vol_props.setdefault('compression', 'lz4')            %}
    {% do vol_props.setdefault('quota', '512M')                   %}
    {% do vol_props.setdefault('sharenfs', 'on')                %}
    {% do vol_props.setdefault('com.sun:auto-snapshot', 'true') %}
zfs_dataset_{{ container_name }}_{{ vol_name }}:
  zfs.filesystem_{{ vol_state }}:
    - name: {{ zpool_name }}/{{ container_name }}/{{ vol_name }}
    {%- if vol_state == 'present' %}
    - properties: {{ vol_props }}
    {% endif %}

zfs_dataset_{{ container_name }}_{{ vol_name }}_perms:
    file.directory:
      - name: /{{ zpool_name }}/{{ container_name }}/{{ vol_name }}
      {%- if vol_user is not none %}
      - user: {{ vol_user }}
      {% endif %}
      {%- if vol_group is not none %}
      - group: {{ vol_group }}
      {% endif %}
      {%- if vol_mode is not none %}
      - mode: {{ vol_mode }}
      {% endif %}
  {% endfor %}
{% endfor %}
