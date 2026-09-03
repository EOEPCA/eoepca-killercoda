Welcome to the **EOEPCA End-to-End Datacube Access** scenario!

This scenario reproduces the workflow from the
[E2E External Data Registration notebook](https://github.com/EOEPCA/demo/blob/main/demoroot/notebooks/08-1%20tb%20E2E%20External%20Data%20Registration%20CF.ipynb):
fetching third-party EO data, reshaping it to the
[STAC Best Practices for Data Cubes](https://github.com/EOEPCA/datacube-access/blob/main/best_practices/stac_best_practices.md)
convention (the **Datacube Access** building block), saving it to a **Workspace**, registering
it with the **Data Access** BB's STAC API, and reading it back as an analysis-ready cube.

### Building Blocks in this environment

This scenario needs IAM, Workspace and Data Access (eoAPI) deployed before the notebook-driven
steps can run. Datacube Access itself is just the STAC Best Practices convention applied by the
notebook - no separate service to deploy. The first step deploys the three BBs live, the same
way every other scenario in this repo does.

A sample datacube-ready STAC collection (`sentinel-2-datacube`) is loaded into eoAPI once
deployment finishes.

### What's next

This is scaffolding for the notebook-driven steps - add them as `NN-*.md` pages here (after the
setup and explore steps) and list them in `index.json`.
