echo setting-up your environment...
#DNS-es for dependencies
echo "127.0.0.1 minio.eoepca.local
127.0.0.1 zoo.eoepca.local" >> /etc/hosts
#Installing Ingress (basic)
echo installing basic ingress...
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
	--set controller.hostNetwork=true &> /tmp/install_ingress.log
#Installing Minio (basic)
echo enabling object storage...
### Prerequisite: minio
wget -q https://dl.min.io/server/minio/release/linux-amd64/minio -O /usr/local/bin/minio && chmod +x /usr/local/bin/minio &> /tmp/install_minio.log
mkdir -p ~/minio && MINIO_ROOT_USER=eoepca MINIO_ROOT_PASSWORD=eoepcatest nohup minio server --quiet ~/minio &>/dev/null &
mkdir -p ~/.eoepca && echo 'export S3_ENDPOINT="http://minio.eoepca.local:9000/"
export S3_ACCESS_KEY="eoepca"
export S3_SECRET_KEY="eoepcatest"' >> ~/.eoepca/state
echo setup complete! you can start the tutorial...