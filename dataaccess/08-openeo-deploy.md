explain that the titiler openeo provides a interface for synchronous OpenEO, which is not to be confused with asynchronous OpenEO used for processing, this is for quick real-time visualizaiton only. It allows you, for example, to do quick band-math operations like an NDVI, but not to compute a complex data product.

there is no helm chart yet for this, I have asked Emmanuel in the chat about what is the plan, an helm chart cna be easily done following https://github.com/sentinel-hub/titiler-openeo/blob/main/docker-compose.yml with basic authentication (so not deploying the keyclock, but using https://github.com/sentinel-hub/titiler-openeo/blob/1e0ce629192baf0278dc7f1ca07f30762148d497/docs/src/admin-guide.md?plain=1#L46

