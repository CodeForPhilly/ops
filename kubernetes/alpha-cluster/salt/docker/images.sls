
{% for name, args in pillar.get('docker', {}).get('images', {}).items() %}
  {% set state = args.pop('state', 'present') %}
docker_image_{{ name }}_{{ state }}:
  dockerng.image_{{ state }}:
    - name: {{ name }}
  {%- for k, v in args.items() %}
    - {{ k }}: {{ v }}
  {% endfor %}
{% endfor %}
