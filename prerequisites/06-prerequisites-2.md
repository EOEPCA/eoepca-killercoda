Now we re-check whether all the prerequisites are met. To do this, we run the `check-prerequisites` script again, answering `no` to the two questions:
```
cd ~/deployment-guide/scripts/infra-prereq
bash check-prerequisites.sh
no
no
```{{exec}}

From the results:
1. Pods can run as `root`
2. Ingress responded successfully
3. ClusterIssuer found
4. PVC 'test-rwx-pvc' successfully bound with ReadWriteMany

All the recommended and optional requirements of our Kubernetes cluster are satisfied!
