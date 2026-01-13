
Congratulations! You have successfully deployed the EOEPCA Application Hub Building Block.


## Next Steps

You can explore more EOEPCA tutorials at [killercoda.com/eoepca](https://killercoda.com/eoepca/).

For more information about the Application Hub and advanced configuration:
- [EOEPCA Website](https://eoepca.org/)
- [EOEPCA GitHub Repository](https://github.com/EOEPCA/)
- [EOEPCA Deployment Guide](https://deployment-guide.docs.eoepca.org/)
- [Application Hub Documentation](https://eoepca.readthedocs.io/projects/application-hub/)
- [JupyterHub Configuration Reference](https://eoepca.github.io/application-hub-context/configuration/)
- [JupyterLab Documentation](https://jupyterlab.readthedocs.io/)

## Uninstallation

To remove the Application Hub:

```bash
helm uninstall application-hub -n application-hub
kubectl delete namespace application-hub
```

If you have questions about this tutorial or EOEPCA in general, contact us at [Eoepca.SystemTeam@telespazio.com](mailto:Eoepca.SystemTeam@telespazio.com)