{% set zpool_name      = pillar['storage'].get('zpool_name', 'kubvols') %}
{% set containers      = pillar['storage'].get('containers', [])        %}
{% set resource_prefix = '/etc/kubernetes/persitent-volumes'            %}

{% for container in  containers %}
  {% set container_name  = container['name'] %}
  {% set container_state = container.get('state', 'present') %}
  {% for vol in container.get('volumes', []) %}
    {% set vol_name  = vol['name']                                    %}
    {% set vol_host  = 'kubvol01'                                     %}
    {% set vol_quota = vol.get('properties', {}).get('quota', '512M') %}
kubernetes_master_init_vol_{{ container_name }}_{{ vol_name }}:
  file.managed:
    - name: {{ resource_prefix }}/{{ container_name }}-{{ vol_name }}.yml
    - makedirs: true
    - source: salt://files/resource-templates/persistent-volume.yml.j2
    - template: jinja
    - storage_path_prefix: /{{ zpool_name }}
    - container_name: {{ container_name }}
    - volume_name: {{ vol_name }}
    - volume_quota: {{ vol_quota }}
    - volume_host: {{ vol_host }}

kubernetes_master_create_vol_{{ container_name }}_{{ vol_name }}:
  cmd.run:
    - name: kubectl create -f {{ resource_prefix }}/{{ container_name }}-{{ vol_name }}.yml
    - unless:
      - kubectl get -f {{ resource_prefix }}/{{ container_name }}-{{ vol_name }}.yml

kubernetes_master_apply_vol_{{ container_name }}_{{ vol_name }}:
  cmd.run:
    - name: kubectl apply -f {{ resource_prefix }}/{{ container_name }}-{{ vol_name }}.yml
    - onchanges:
      - file: kubernetes_master_init_vol_{{ container_name }}_{{ vol_name }}
  {% endfor %}
{% endfor %}
