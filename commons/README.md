This folder contains general script for setting up EOEPCA pre-requisites in the tutorial environments.

To add it to your tutorials, you need to, in your tutorial folder:

1. edit your `index.json` end ensure you have configured foreground and background scripts and assets via

```json
[...]
    "intro": {
      "title": "Intro",
      "text": "intro.md",
      "foreground": "intro_foreground.sh",
      "background": "intro_background.sh"
    },
[...]
    "assets": {
      "host01": [
        {"file": "*", "target": "/tmp/assets/"}
      ]
    }
```

2. create a symbolic links of the `intro_foreground.sh` and `intro_background.sh` scripts from the `commons` directory, e.g. via

```bash
ln -s ../../commons/intro_* ./
```

3. create an `assets` folder (needs to be a pysical folder, not a symbolic link) and a symbolic link in this folder to the assets relative to the pre-equisites you want to set. For example, to add the gomplate prerequisite, you need to do

```bash
mkdir -p assets
cd assets
ln -s ../../commons/assets/gomplate.7x ./
```
The available assets you can select are described in the following table. Please note that the more pre-requise you set, the slower will be the tutorial setup and more resources will be required for it, so select only the pre-requisites you really need!


| Asset file to mount | Pre-requisite installed |
| --- | --- |
| `gomplate.7z` | gomplate software. Required by most EOEPCA deployment-guide script |
| `ignoreresrequests` | install gatekeeper with mutation hook to override all resource requests, setting them to 0 (disabled). This allows to avoid honoring resource requests which may not be available in the killercoda environment |
| `localdns` | /etc/hosts configuration with eoepca.local dns entries pointing to the local ingress. Fill the localdns file in the asset folder with a space-separated list of hosts to be mapped |
| `minio.7z` | minio s3 storage service installed locally (NOTE: no buckets are created. To create a bucket use `miniobuckets` below) |
| `miniobuckets` | minio buckets. Requires minio.7z to be enabled. Contains a space-separated list of buckets to be created |
| `nginxingress` | nginx ingress installed in the K8S cluster |
| `readwritemany` | local storage class supporting ReadWriteMany K8S persistent volumes provisioning |
| `htcondor` | HPC batch system (HTCondor) |
| `killercodaproxy` | Install a local proxy and cofigure it to proxy the internal ingress on an external host name with domain substitution. To configure it, set in the file a port , a destination and a content type. For example, with `81 resource-catalogue.eoepca.local 'application/json text/html'` it will allow you to access the `resource-catalogue.eoepca.local` service via `{{TRAFFIC_HOST1_81}}` and replace in all the `application/json` and `text/html` pages the `resource-catalogue.eoepca.local` address with `{{TRAFFIC_HOST1_81}}` |
