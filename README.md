# Keycloak + Postgres + Nginx Ansible Project

This structure is organized around two files:

- [group_vars/all.yml](/Users/alexkgm/keycloak-postgres-docker/group_vars/all.yml): where you set the target host IP and all editable app/env/TLS settings
- [site.yml](/Users/alexkgm/keycloak-postgres-docker/site.yml): the main playbook entrypoint

## Project Structure

```text
.
├── ansible.cfg
├── group_vars/
│   └── all.yml
├── inventory/
│   └── hosts.yml
├── justfile
├── site.yml
└── roles/
    └── keycloak_stack/
        ├── tasks/
        │   ├── main.yml
        │   ├── preflight.yml
        │   ├── system.yml
        │   ├── deploy.yml
        │   ├── nginx.yml
        │   └── summary.yml
        └── templates/
            ├── docker-compose.yml.j2
            ├── keycloak.env.j2
            └── keycloak.nginx.j2
```

## 1. Set Config In `group_vars/all.yml`

Edit [group_vars/all.yml](/Users/alexkgm/keycloak-postgres-docker/group_vars/all.yml):

```yaml
target_host_ip: "203.0.113.10"
target_host_user: ubuntu
target_host_port: 22
target_host_private_key_file: "{{ lookup('env', 'HOME') }}/.ssh/github-actions-key"
target_host_ssh_config_file: "{{ lookup('env', 'HOME') }}/.ssh/config"
```

That same file also holds:

- Keycloak admin username/password
- Postgres password
- domain and Let's Encrypt email
- realm and client bootstrap config
- project directory
- theme/provider JAR path
- package lists
- optional extra SSH args

If `keycloak_domain` and `letsencrypt_email` stay empty, the deployment uses plain HTTP on the host IP.

## 2. Deploy

```bash
just deploy
```

Other useful commands:

```bash
just check
just syntax
```

## HTTPS

Let's Encrypt does not issue certificates for a bare IP. For HTTPS, set these values in [group_vars/all.yml](/Users/alexkgm/keycloak-postgres-docker/group_vars/all.yml):

```yaml
keycloak_domain: keycloak.example.com
letsencrypt_email: you@example.com
```

Then run `just deploy`.

## Realm Bootstrap

By default the deploy now also ensures:

- realm: `a8s`
- clients: `a8s-frontend`, `a8s-frontend-local`

Those values live in [group_vars/all.yml](/Users/alexkgm/keycloak-postgres-docker/group_vars/all.yml), including the default redirect URIs and web origins for each client.

## Notes

- The playbook currently targets Debian/Ubuntu hosts.
- Generated passwords are stored in `./.ansible/generated/` when you leave them empty in `group_vars/all.yml`.
- Local provider/theme directories are supported if you create `./keycloak/providers/` or `./keycloak/themes/`.
- This project does not use a service-account key file. If you later add Google Cloud automation, use ADC instead.
- If SSH still says `Permission denied (publickey)`, the server likely does not have the matching public key in `~/.ssh/authorized_keys` for `target_host_user`.
