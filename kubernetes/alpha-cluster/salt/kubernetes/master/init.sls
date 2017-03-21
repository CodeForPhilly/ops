# Toggle guards against provisioning cluster resources
# before cluser itself has been provisioned
{% if pillar.get('kubernetes', {}).get('master', {}).get('enabled') %}
include:
  - kubernetes.master.persistent_volumes
{% endif %}
