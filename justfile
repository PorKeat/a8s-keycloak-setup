set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

deploy: prepare
    ANSIBLE_CONFIG=./ansible.cfg ANSIBLE_LOCAL_TEMP=./.ansible/tmp ansible-playbook -i inventory/hosts.yml site.yml

destroy: prepare
    ANSIBLE_CONFIG=./ansible.cfg ANSIBLE_LOCAL_TEMP=./.ansible/tmp ansible-playbook -i inventory/hosts.yml -e keycloak_stack_state=absent site.yml

check: prepare
    ANSIBLE_CONFIG=./ansible.cfg ANSIBLE_LOCAL_TEMP=./.ansible/tmp ansible-playbook -i inventory/hosts.yml site.yml --check

syntax: prepare
    ANSIBLE_CONFIG=./ansible.cfg ANSIBLE_LOCAL_TEMP=./.ansible/tmp ansible-playbook -i inventory/hosts.yml --syntax-check site.yml

prepare:
    mkdir -p .ansible/tmp .ansible/generated .ansible/cp
