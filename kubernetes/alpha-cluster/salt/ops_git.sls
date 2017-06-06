
{% set args = pillar.get('ops', {}).get('git', {}) %}
{% do args.setdefault('name', 'https://github.com/CodeForPhilly/ops.git') %}
{% do args.setdefault('target', '/opt/ops') %}

ops_git_current:
  git.latest:
{%- for k, v in args.items() %}
    - {{ k }}: {{ v }}
{% endfor %}
