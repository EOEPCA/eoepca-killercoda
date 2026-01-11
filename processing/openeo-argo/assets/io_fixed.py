import logging
import numpy as np
import os
import pyproj
import pystac_client
import xarray as xr

from odc.stac import stac_load
from pathlib import Path
from pystac.extensions import raster
from typing import Optional, Union
from openeo_processes_dask.process_implementations.data_model import (
    RasterCube
)
from openeo_processes_dask.process_implementations.cubes._filter import filter_bbox
from openeo_pg_parser_networkx.pg_schema import BoundingBox, GeoJson, TemporalInterval

__all__ = ["load_collection", "save_result"]

def load_collection(
    id: str,
    spatial_extent: Optional[Union[BoundingBox, dict, str, GeoJson]] = None,
    temporal_extent: Optional[TemporalInterval] = None,
    bands: Optional[list[str]] = None,
    properties: Optional[dict] = None,
    **kwargs,
):
    query_dict = {}

    query_dict["collections"] = [id]

    if spatial_extent is None:
        raise Exception(
            "No spatial extent was provided, will not load the entire x and y axis of the datacube."
        )
    elif temporal_extent is None:
        raise Exception(
            "No temporal extent was provided, will not load the entire temporal axis of the datacube."
        )

    if isinstance(spatial_extent, BoundingBox):
        query_dict["bbox"] = (
            spatial_extent.west,
            spatial_extent.south,
            spatial_extent.east,
            spatial_extent.north,
        )
    else:
        raise ValueError("Provided spatial extent could not be interpreted.")

    query_dict["datetime"] = tuple(
        [str(time.root) for time in temporal_extent if time != 'None']
    )

    if "STAC_API_URL" not in os.environ:
        raise Exception("STAC URL Not available in executor config.")

    catalog = pystac_client.Client.open(os.environ["STAC_API_URL"])
    results = catalog.search(**query_dict, limit=10)

    result_items = list(results.items())

    example_item = result_items[0]

    if "proj:wkt2" in example_item.properties.keys():
        crs = pyproj.CRS.from_wkt(example_item.properties["proj:wkt2"])
    elif "proj:epsg" in example_item.properties.keys():
        crs = pyproj.CRS.from_epsg(example_item.properties["proj:epsg"])

    if raster.RasterExtension.has_extension(example_item):
        for asset in example_item.get_assets().values():
            if 'raster:bands' in asset.extra_fields.keys():
                for band in asset.extra_fields['raster:bands']:
                    if 'spatial_resolution' in band:
                        resolution = band['spatial_resolution']
                    if 'nodata' in band:
                        nodata = band['nodata']
                    if 'data_type' in band:
                        dtype = band['data_type']
            if resolution and nodata and dtype:
                break
    else:
        # FIX 1: crs is already a CRS object, don't call from_wkt on it
        crs_measurement = crs.axis_info[0].unit_name

        if crs_measurement == 'metre':
            resolution = 10
        elif crs_measurement == 'degree':
            resolution = 0.0009
        
    # TODO Need to tidy up the logic above.
    kwargs = {}
    # TODO Need to ensure nodata belongs to the dtype
    if dtype:
        kwargs["dtype"] = dtype

        if "int" in dtype and isinstance(nodata, float):
            nodata = int(nodata)

    if nodata:
        kwargs["nodata"] = nodata       

    lazy_xarray = stac_load(
        result_items,
        crs=crs,
        resolution=resolution,
        # TODO Add some way to decide chunks
        chunks={"x": 2048, "y": 2048},
        **kwargs
    ).to_array(dim='bands')

    # Add some sort of clipping here to the original bounding box that was requested.
    return filter_bbox(lazy_xarray, extent=spatial_extent)

def save_result(
    data: RasterCube,
    format: str = 'netcdf',
    options: Optional[dict] = None,
):
    """ """
    def clean_unused_coordinates(ds):
        """
        Remove all coordinates that are not used in the DataArray dimensions.
        """
        # Gather all dimensions used by DataArray variables
        used_dims = set()
        for var in ds.dims:
            used_dims.update(ds[var].dims)

        # Drop unused coordinates
        for coord in list(ds.coords):
            if coord not in used_dims:
                ds = ds.drop_vars(coord)
        return ds

    import uuid

    logging.info("DATA ", data)
    logging.info("DATA ATTRS ", data.attrs)

    _id = str(uuid.uuid4())
    # TODO A nice abstraction to split the xarray into the respective output datasets
    # TODO Some nicer way to handle the user workspace
    destination = Path(os.environ["OPENEO_RESULTS_PATH"]) / f"{_id}.nc"
    dim = data.openeo.band_dims[0] if data.openeo.band_dims else None
    
    # FIX 2: Get CRS from spatial_ref coordinate instead of data.crs (which doesn't exist)
    crs = None
    if "spatial_ref" in data.coords and "crs_wkt" in data.coords["spatial_ref"].attrs:
        crs = data.coords["spatial_ref"].attrs["crs_wkt"]
    
    data.attrs = {}
    data.attrs["crs"] = str(crs)

    out_data: xr.Dataset = data.to_dataset(
        dim=dim, name="name" if not dim else None, promote_attrs=True
    )

    dtype = None
    if not dtype:
        dtype = "float32"

    comp = dict(zlib=True, complevel=5, dtype=dtype)
    
    encoding = {var: comp for var in out_data.data_vars}
    out_data = clean_unused_coordinates(out_data)

    out_data.to_netcdf(path=destination, encoding=encoding)