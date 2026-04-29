set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

deploy: ensure-config prepare
    ANSIBLE_CONFIG=./ansible.cfg ANSIBLE_LOCAL_TEMP=./.ansible/tmp ansible-playbook -i inventory/hosts.yml site.yml

destroy: ensure-config prepare
    ANSIBLE_CONFIG=./ansible.cfg ANSIBLE_LOCAL_TEMP=./.ansible/tmp ansible-playbook -i inventory/hosts.yml -e keycloak_stack_state=absent site.yml

check: ensure-config prepare
    ANSIBLE_CONFIG=./ansible.cfg ANSIBLE_LOCAL_TEMP=./.ansible/tmp ansible-playbook -i inventory/hosts.yml site.yml --check

syntax: ensure-config prepare
    ANSIBLE_CONFIG=./ansible.cfg ANSIBLE_LOCAL_TEMP=./.ansible/tmp ansible-playbook -i inventory/hosts.yml --syntax-check site.yml

init-config:
    test -f group_vars/all.local.yml || cp group_vars/all.example.yml group_vars/all.local.yml

ensure-config:
    test -f group_vars/all.local.yml || { echo "Missing group_vars/all.local.yml. Run 'just init-config' first."; exit 1; }

prepare:
    mkdir -p .ansible/tmp .ansible/generated .ansible/cp
