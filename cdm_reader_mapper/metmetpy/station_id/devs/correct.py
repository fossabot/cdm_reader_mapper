#!/usr/bin/env python3
"""
Created on Tue Jun 25 09:00:19 2019

Forces id field format comformity in 2 stages:
    1. corrects deck specific known errors in names/callsigns
    2. applies common format comformity rules

To account for dataframes stored in TextParsers and for eventual use of data columns other
than those to be fixed in this or other metmetpy modules,
the input and output are the full data set.

Specific corrections/replacememnts (stage 1) to apply are data model and deck
specific and are registered in ./lib/data_model.json.

The deck is accessed from the corresponding data model column. Multiple decks
are not supported. In the event of multiple decks in the input data, the module
will return with no output (will break full processing downstream of its
invocation) logging an error.

Reference names of different metadata fields used in the metmetpy modules
and its location column|(section,column) in a data model are
registered in ../properties.py in metadata_datamodels.

If the data model is not available in ./lib it is assumed to no corrections are
needed (no stage 1). It will just log a warning.
If the data model is not available in metadata_models, the module
will return with no output (will break full processing downstream of its
invocation) logging an error.

After stage 1, id is supposed to be ascii.....

Some of the ID corrections assume that the id field read from the source has
not been white space stripped. Care must be taken that the way a data model
is read before input to this module, is coherent to the way corrections are
performed for that data model.

DEV NOTES:
As with platform_type in metmetpy, dataset must be a paramter to this
functions, not just data model. The dataset.py will have the correction functions
(like icoads_r3000.py in here)



@author: iregon
"""

import importlib
import json
import os
from io import StringIO

import numpy as np
import pandas as pd

from cdm_reader_mapper.common import logging_hdlr

from .. import properties


class smart_dict(dict):
    def __init__(self, *args):
        dict.__init__(self, *args)

    def __getitem__(self, key):
        val = dict.__getitem__(self, key)
        return val

    def __setitem__(self, key, val):
        dict.__setitem__(self, key, val)

    def __missing__(self, key):
        key = key
        return key


tool_name = "metmetpy"
module_path = os.path.dirname(os.path.abspath(__file__))

functions_module_path = os.path.join(module_path, "correction_functions")
functions_module_tree = functions_module_path[
    functions_module_path.find("/" + tool_name + "/") + 1 :
].split("/")
id_functions_mdl = importlib.import_module(
    ".".join(functions_module_tree), package=None
)

correction_method_path = os.path.join(module_path, "lib")
cor_maps_path = os.path.join(module_path, "correction_maps")


def correct_it(data, data_model, deck, log_level="INFO"):
    logger = logging_hdlr.init_logger(__name__, level=log_level)

    id_col = properties.metadata_datamodels["id"].get(data_model)

    # Optional deck specific corrections
    correction_method_file = os.path.join(correction_method_path, data_model + ".json")
    with open(correction_method_file) as fileObj:
        correction_method = json.load(fileObj)

    id_correction = correction_method.get(deck)
    if not id_correction or not id_correction.get("corrections"):
        logger.info(
            f"No replacements to apply to deck {deck} data from data\
                model {data_model}"
        )
    else:
        logger.info(
            'Applying "{}" replacement method'.format(
                id_correction.get("corrections").get("method")
            )
        )
        try:
            for method, correction in id_correction.items():
                if method == "fillna":
                    data[id_col].iloc[np.where(data[id_col].isna())] = correction
                elif method == "map":
                    cor_map_name = correction
                    rep_map_file = os.path.join(cor_maps_path, cor_map_name + ".json")
                    with open(rep_map_file) as fileObj:
                        rep_map = json.load(fileObj)
                    data[id_col] = data[id_col].map(smart_dict(rep_map))
                elif method == "function":
                    transform = id_correction.get("function")
                    trans = eval("id_functions_mdl." + transform)
                    data = trans(data)
                elif method == "replace_patterns":
                    replacements = id_correction.get("replace_patterns")
                    data[id_col] = data[id_col].replace(replacements, regex=True)
                #                    for pattern,replacement in correction.items():
                #                        data[id_col].str.replace(pattern, replacement,regex=True)
                else:
                    logger.error(
                        f"ID correction method {method} unknow to metmetpy.station_id.correct module"
                    )
                    return
        except Exception:
            logger.error("Applying replacement", exc_info=True)
            return
    return data


def correct(data, data_model, deck, log_level="INFO"):
    logger = logging_hdlr.init_logger(__name__, level=log_level)

    correction_methods_file = os.path.join(correction_method_path, data_model + ".json")
    if not os.path.isfile(correction_methods_file):
        logger.error(f"Data model {data_model} has no corrections in library")
        return

    id_col = properties.metadata_datamodels["id"].get(data_model)

    if not id_col:
        logger.error(
            f"Data model {data_model} ID column not defined in\
                     properties file"
        )
        return

    if isinstance(data, pd.DataFrame):
        data = correct_it(data, data_model, deck, log_level="INFO")
        return data
    elif isinstance(data, pd.io.parsers.TextFileReader):
        read_params = [
            "chunksize",
            "names",
            "dtype",
            "parse_dates",
            "date_parser",
            "infer_datetime_format",
        ]
        read_dict = {x: data.orig_options.get(x) for x in read_params}
        buffer = StringIO()
        for df in data:
            df = correct_it(df, data_model, deck, log_level="INFO")
            df.to_csv(buffer, header=False, index=False, mode="a")

        buffer.seek(0)
        return pd.read_csv(buffer, **read_dict)
