
## Prerequisites and Initial Configuration

Initial cleanups:

```bash
apt remove firefox
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
puma['per_worker_max_memory_mb'] = 1024
sidekiq['min_concurrency'] = 1
sidekiq['max_concurrency'] = 2
postgresql['shared_buffers'] = "256MB"
postgresql['max_worker_processes'] = 4
gitaly['configuration'] = {
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
gitaly['env'] = {
  'GITALY_COMMAND_SPAWN_MAX_PARALLEL' => '2'
}
prometheus_monitoring['enable'] = false
alertmanager['enable'] = false
gitlab_exporter['enable'] = false

registry['enable'] = false
gitlab_kas['enable'] = false

gitlab_rails['env'] = {
  'MALLOC_CONF' => 'dirty_decay_ms:1000,muzzy_decay_ms:1000'
}

gitaly['env'] = {
  'MALLOC_CONF' => 'dirty_decay_ms:1000,muzzy_decay_ms:1000'
}
EOF
docker run -p 8080:80 --name gitlab -d -v $PWD/gitlab.rb:/etc/gitlab/gitlab.rb gitlab/gitlab-ce:18.0.0-ce.0
```{{exec}}

```bash
export INGRESS_HOST={{TRAFFIC_HOST1_30080}}
export GITLAB_URL={{TRAFFIC_HOST1_8080}}
```

We will also supply you with the Gitlab and secret for this demonstration.

```bash
export PATH_BASED_ROUTING=true
export GITLAB_APP_ID=""
export GITLAB_APP_SECRET=""
```

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