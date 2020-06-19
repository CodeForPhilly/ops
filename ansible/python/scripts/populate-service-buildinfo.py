import sys
import json
import pathlib
import re

inputs = json.loads(sys.stdin.read())

project_name         = inputs['project_name']
project_repo_url     = inputs['project_repo_url']
project_repo_path    = inputs['project_repo_path']
project_ref          = inputs['project_ref']
project_compose_file = inputs['project_compose_file']
project_compose_cfg  = inputs['project_compose_cfg']
project_svcs         = inputs['services']

outputs = []

if __name__ == '__main__':

    for svc in project_svcs:

        compose_cfg_svc = project_compose_cfg.get('services', {}).get(svc['name'])
        if not hasattr(compose_cfg_svc, 'get'):
            continue

        build_cfg = compose_cfg_svc.get('build')

        if build_cfg:

            dockerfile_context    = None
            dockerfile_name       = None
            dockerfile_args       = None
            dockerfile_img_name   = '{}_{}'.format(project_name, svc['name'])
            dockerfile_img_tag    = project_ref

            if hasattr(build_cfg, 'get'):
                dockerfile_context = build_cfg['context']
                dockerfile_name    = build_cfg.get('dockerfile')
                dockerfile_args    = build_cfg.get('args')
            else:
                dockerfile_context = build_cfg

            # Enforce docker context as repo url
            if not re.match(r'^[a-z]+://', dockerfile_context):
                repo_path          = pathlib.Path(project_repo_path)
                compose_file_path  = repo_path.joinpath(project_compose_file)
                context_path       = compose_file_path.parent.joinpath(dockerfile_context)
                context_subpath    = context_path.relative_to(repo_path)
                dockerfile_context = '{}#{}:{}'.format(project_repo_url, project_ref, context_subpath)

            svc['container_opts']['build'] = {
                'image'              : '{}:{}'.format(dockerfile_img_name, dockerfile_img_tag),
                'dockerfile_context' : dockerfile_context,
            }

            if dockerfile_name:
                svc['container_opts']['build']['dockerfile_name'] = dockerfile_name

            if dockerfile_args:
                svc['container_opts']['build']['dockerfile_args'] = dockerfile_args

        outputs.append(svc)

    sys.stdout.write(json.dumps(outputs))
    sys.exit(0)
