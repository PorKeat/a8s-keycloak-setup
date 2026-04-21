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
        │   ├── destroy.yml
        │   ├── identity.yml
        │   ├── identity_client.yml
        │   ├── identity_provider.yml
        │   ├── identity_user.yml
        │   ├── identity_user_client_role.yml
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
- optional TLS expected public IP override
- stack state and destroy behavior flags
- realm and client bootstrap config
- project directory
- theme/provider JAR path and realm login theme
- package lists
- optional extra SSH args

If `keycloak_domain` and `letsencrypt_email` stay empty, the deployment uses plain HTTP on the host IP.

## 2. Deploy

```bash
just deploy
```

Other useful commands:

```bash
just destroy
just check
just syntax
```

`just destroy` runs the same playbook in destroy mode and removes the deployed Keycloak stack from the target host.

For quick git pushes from this repo, you can also use:

```bash
./auto_push.sh "your commit message"
```

## HTTPS

Let's Encrypt does not issue certificates for a bare IP. For HTTPS, set these values in [group_vars/all.yml](/Users/alexkgm/keycloak-postgres-docker/group_vars/all.yml):

```yaml
keycloak_domain: keycloak.example.com
letsencrypt_email: you@example.com
```

Then run `just deploy`.

If Let's Encrypt fails, make sure the domain A record points to the public server IP that should answer on port `80`. By default the playbook expects `keycloak_domain` to resolve to `target_host_ip`. If your TLS traffic goes through a different public IP such as a load balancer, set `keycloak_tls_expected_ips` in [group_vars/all.yml](/Users/alexkgm/keycloak-postgres-docker/group_vars/all.yml).

## Realm Bootstrap

By default the deploy now also ensures:

- realm: `a8s`
- login theme: `keycloakify-starter`
- realm user: `a8s-admin` with a configurable password
- identity providers: `github`, `gitlab`, `google`
- clients: `a8s-frontend`, `a8s-frontend-local`

Those values live in [group_vars/all.yml](/Users/alexkgm/keycloak-postgres-docker/group_vars/all.yml), including the realm login theme, identity provider settings, realm users, passwords, role mappings, and the default redirect URIs and web origins for each client.

## Notes

- The playbook currently targets Debian/Ubuntu hosts.
- Generated passwords are stored in `./.ansible/generated/` when you leave them empty in `group_vars/all.yml`.
- Local provider/theme directories are supported if you create `./keycloak/providers/` or `./keycloak/themes/`.
- This repo already contains a provider JAR at `provider/keycloak-theme-for-kc-all-other-versions.jar`, and the playbook now uses it by default as the `keycloakify-starter` login theme.
- The social identity provider client secrets in [group_vars/all.yml](/Users/alexkgm/keycloak-postgres-docker/group_vars/all.yml) are placeholders until you replace them with the real GitHub, GitLab, and Google secrets.
- This project does not use a service-account key file. If you later add Google Cloud automation, use ADC instead.
- If SSH still says `Permission denied (publickey)`, the server likely does not have the matching public key in `~/.ssh/authorized_keys` for `target_host_user`.
- Destroy behavior is controlled by `keycloak_destroy_remove_volumes`, `keycloak_destroy_remove_project_dir`, `keycloak_destroy_remove_tls_assets`, and `keycloak_destroy_restore_default_nginx_site` in [group_vars/all.yml](/Users/alexkgm/keycloak-postgres-docker/group_vars/all.yml).
