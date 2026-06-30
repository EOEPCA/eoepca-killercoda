We have used EODAG as the implementation of the EOEPCA Data Gateway and exercised the same gateway through three interfaces.

You've explored:

- Installing and configuring EODAG
- Listing available providers and product types
- Discovering product types from a live provider
- Searching and normalising EO product metadata with the CLI
- Observing automatic provider fallback
- Querying an explicitly selected provider through a STAC API
- Using the Python API to inspect products and their data assets

### Key Takeaways

- The gateway is a consistent client interface, not a central copy of provider data.
- Product types give workflows stable dataset identifiers across different backends.
- EODAG normalises provider-specific protocols and metadata into common searches and product objects.
- Provider coverage, authentication, metadata, and assets still differ, so provider choice remains visible and controllable.
- STAC provides an interoperable HTTP boundary, while the Python API is the natural choice for direct workflow integration.
- Large product downloads should be planned deliberately; discovery and metadata searches are lightweight by comparison.

For more information:

- [EOEPCA Website](https://eoepca.org/)
- [EOEPCA Git Repository](https://github.com/EOEPCA/)
- [EOEPCA Deployment Guide](https://eoepca.readthedocs.io/projects/deploy/en/latest/)
- [EODAG Documentation](https://eodag.readthedocs.io/)
- [EODAG GitHub Repository](https://github.com/CS-SI/eodag)
- [STAC Specification](https://stacspec.org/en)

If you have questions about this tutorial, EOEPCA in general or specific EOEPCA applications, contact us at [Eoepca.SystemTeam@telespazio.com](mailto:Eoepca.SystemTeam@telespazio.com)
