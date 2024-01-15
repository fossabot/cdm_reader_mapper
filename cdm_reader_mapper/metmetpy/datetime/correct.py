#!/usr/bin/env python3
"""
Created on Tue Jun 25 09:00:19 2019

Corrects datetime fields from a given deck in a data model.

To account for dataframes stored in TextParsers and for eventual use of data columns other
than those to be fixed in this or other metmetpy modules,
the input and output are the full data set.

Correctionsare data model and deck specific and are registered
in ./lib/data_model.json: multiple decks in the same input data are not
 supported.

Reference names of different metadata fields used in the metmetpy modules
and its location column|(section,column) in a data model are
registered in ../properties.py in metadata_datamodels.

If the data model is not available in ./lib it is assumed to no corrections are
needed.
If the data model is not available in metadata_models, the module
will return with no output (will break full processing downstream of its
invocation) logging an error.


@author: iregon
"""

import json
import os
from io import StringIO

import pandas as pd

from cdm_reader_mapper.common import logging_hdlr

from . import correction_functions


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


# tool_name = "metmetpy"
module_path = os.path.dirname(os.path.abspath(__file__))
# functions_module_path = os.path.join(module_path, "correction_functions")
# functions_module_tree = functions_module_path[
#   functions_module_path.find("/" + tool_name + "/") + 1 :
# ].split("/")
# datetime_functions_mdl = importlib.import_module(
#   ".".join(functions_module_tree), package=None
# )

module_path = os.path.dirname(os.path.abspath(__file__))
correction_method_path = os.path.join(module_path, "library")


def correct_it(data, data_model, deck, log_level="INFO"):
    logger = logging_hdlr.init_logger(__name__, level=log_level)

    # 1. Optional deck specific corrections
    correction_method_file = os.path.join(correction_method_path, data_model + ".json")
    if not os.path.isfile(correction_method_file):
        logger.info(f"No datetime corrections {data_model}")
    else:
        with open(correction_method_file) as fileObj:
            correction_method = json.load(fileObj)
        datetime_correction = correction_method.get(deck, {}).get("function")
        print(correction_method.get(deck, {}))
        if not datetime_correction:
            logger.info(
                f"No datetime correction to apply to deck {deck} data from data\
                        model {data_model}"
            )
        else:
            logger.info(f'Applying "{datetime_correction}" datetime correction')
            try:
                # trans = eval("datetime_functions_mdl." + datetime_correction)
                trans = getattr(correction_functions, datetime_correction)
                trans(data)
            except Exception:
                logger.error("Applying correction ", exc_info=True)
                return

    return data


def correct(data, data_model, deck, log_level="INFO"):
    logger = logging_hdlr.init_logger(__name__, level=log_level)

    replacements_method_file = os.path.join(
        correction_method_path, data_model + ".json"
    )
    if not os.path.isfile(replacements_method_file):
        logger.warning(f"Data model {data_model} has no replacements in library")
        logger.warning(
            "Module will proceed with no attempt to apply id\
                       replacements".format()
        )

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
