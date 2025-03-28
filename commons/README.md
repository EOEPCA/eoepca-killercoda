This folder contains general script for setting up EOEPCA pre-requisites in the tutorial environments.

To add it to your tutorials, you need to:

1. do a symbolic links of the `intro_foreground.sh` and `intro_background.sh` scripts and `assets` folder in the tutorial mail folder

2. add them to the "intro" step of the `index.json` via

```json
    "intro": {
      "title": "Intro",
      "text": "intro.md",
      "foreground": "intro_foreground.sh",
      "background": "intro_background.sh"
    },
```

3. mount the assets you need in the tutorial, the intro script will accordingly setup the given pre-requisite. Assets can be mounted by adding in the json the following

```json
    "assets": {
      "host01": [
        {"file": "gomplate.7z", "target": "/tmp/assets/"}
      ]
    }
```

The available assets to mount are in the following table. Please note that the more pre-requise you set, the slower will be the tutorial setup and more resources will be required for it, so select only the pre-requisites you really need!


| Asset file to mount | Pre-requisite installed |
| --- | --- |
| `gomplate.7z` | gomplate software. Required by most EOEPCA deployment-guide script |
| `ignoreresrequests` | install gatekeeper with mutation hook to override all resource requests, setting them to 0 (disabled). This allows to avoid honoring resource requests which may not be available in the killercoda environment |
| `localdns` | /etc/hosts configuration with eoepca.local dns entries pointing to the local ingress |
| `minio.7z` | minio s3 storage service installed locally |
| `nginxingress` | nginx ingress installed in the K8S cluster |
| `readwritemany` | local storage class supporting ReadWriteMany K8S persistent volumes provisioning |


