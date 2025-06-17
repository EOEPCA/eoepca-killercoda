
## Prerequisites and Initial Configuration

Initial cleanups:

```bash
apt remove firefox -y
apt autoremove -y
rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/apt/archives/*
rm -rf /var/cache/apt/archives/partial/*
crictl rmi --prune
```{{exec}}


Clone deployment scripts:

```bash
git clone https://github.com/EOEPCA/deployment-guide.git -b killercoda-jh-changes

cd deployment-guide/scripts/mlops
```{{exec}}

```bash
cat <<EOF > gitlab.rb
puma['worker_processes'] = 0
puma['min_threads'] = 1
puma['max_threads'] = 1
puma['per_worker_max_memory_mb'] = 650

sidekiq['concurrency'] = 5

postgresql['shared_buffers'] = "256MB"
postgresql['max_worker_processes'] = 4
postgresql['max_connections'] = 100
postgresql['effective_cache_size'] = '512MB'

gitaly['configuration'] = {
  git: {
    catfile_cache_size: 10
  },
  concurrency: [
    {
      'rpc' => "/gitaly.SmartHTTPService/PostReceivePack",
      'max_per_repo' => 3,
    }, {
      'rpc' => "/gitaly.SSHService/SSHUploadPack",
      'max_per_repo' => 3,
    },
  ]
}

prometheus_monitoring['enable'] = false
alertmanager['enable'] = false
node_exporter['enable'] = false
redis_exporter['enable'] = false
postgres_exporter['enable'] = false
gitlab_exporter['enable'] = false
registry['enable'] = false
gitlab_kas['enable'] = false
gitlab_pages['enable'] = false
spamcheck['enable'] = false

gitlab_rails['env'] = {
  'MALLOC_CONF' => 'dirty_decay_ms:1000,muzzy_decay_ms:1000'
}
gitaly['env'] = {
  'GITALY_COMMAND_SPAWN_MAX_PARALLEL' => '2',
  'MALLOC_CONF' => 'dirty_decay_ms:1000,muzzy_decay_ms:1000'
}
gitlab_workhorse['env'] = {
  'MALLOC_CONF' => 'dirty_decay_ms:1000,muzzy_decay_ms:1000'
}
EOF
docker run -p 8080:80 --name gitlab -d -v $PWD/gitlab.rb:/etc/gitlab/gitlab.rb gitlab/gitlab-ce:18.0.0-ce.0
```{{exec}}

```bash
export INGRESS_HOST=$(echo "{{TRAFFIC_HOST1_30080}}" | sed -E 's~^https?://~~;s~/.*~~')
export GITLAB_URL={{TRAFFIC_HOST1_8080}}
export PATH_BASED_ROUTING=true
```{{exec}}

Run the prerequisites check:

```bash
bash check-prerequisites.sh <<EOF
http
nginx
no
local-path
no
EOF
```{{exec}}