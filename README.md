# Elephant Project

## Overview

A voyage of discovery, leveraging Infrastructure-As-Code (IaC) principles to create a highly-available PostgreSQL cluster, utilising open source tools and libraries, such as Patroni for automated failover and replication and pgbackrest for backups to name a few, along with other utilities to configure concepts independently of the projects main function(s) for learning purposes.

## Table of Contents

- [Elephant Project](#elephant-project)
  - [Overview](#overview)
  - [Table of Contents](#table-of-contents)
  - [Prerequisites](#prerequisites)
  - [Architectural Components](#architectural-components)
  - [Getting Started](#getting-started)
  - [Core Concepts](#core-concepts)
    - [Automatic Failover](#automatic-failover)
    - [Replication](#replication)

## Prerequisites

- A [Vultr](vultr.com) account with an API Key.
- [OpenTofu](https://opentofu.org/)
- [Ansible](https://docs.ansible.com/projects/ansible/latest/index.html)

## Architectural Components

- 2 database servers for our PostgreSQL instances.
- 3 additional servers for our choice of Distributed Configuration Store `etcd`.

## Getting Started

1. Change into the OpenTofu directory.

```bash
cd tofu
```

2. Initialise the working directory.

```bash
tofu init
```

3. Create the underlying infrastructure.

> You must provide your API Key before executing the below command. This can be added to a variable file as `vultr_api_key`. The created variable file can then be passed to the command using the `-var-file` parameter.

```bash
tofu apply -auto-approve
```

> You can add the created API Key to a variable file, which can then be passed to the above command using the `-var-file` parameter.

4. Setup the Ansible.

```bash
python3 -m venv .venv && . .venv/bin/activate && python3 -m pip install -r requirements.txt
```

5. Configure a highly-available PostgreSQL cluster.

> You must export your API Key as `VULTR_API_KEY` before executing the below command.

```bash
ansible-playbook -i inventories/vultr.yml ./playbooks/provision/ha.yml
```

## Core Concepts

### Automatic Failover

[Patroni](https://patroni.readthedocs.io/en/latest/) is used to implement automatic failover.

### Replication

Since the project uses [Patroni](https://patroni.readthedocs.io/en/latest/), it will configure the cluster for streaming replication by default, however, a role to configure streaming replication between two PostgreSQL instances can be found in the `./playbooks/replication/configure.yml` playbook.
