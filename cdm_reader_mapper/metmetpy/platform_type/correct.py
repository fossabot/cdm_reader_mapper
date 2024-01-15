#!/usr/bin/env python3
"""
Created on Tue Jun 25 09:00:19 2019

Corrects the platform type field of data from a given data model. To account
for dataframes stored in TextParsers and for eventual use of data columns other
than those to be fixed (depedencies) in this or other metmetpy modules,
the input and output are the full data set.

Correction to apply is data model and deck specific and is registered in
./lib/data_model.json: multiple decks in input data are not supported.

The ones in imma1 (only available so far) come from
Liz's construct_monthly_files.R. PT corrections are rather simple with no
dependencies other than dck and can be basically classified in:
    - for a set of decks, set missing PT to known type 5.
    - for a set of decks, set PT=4,5 to 99: state nan. This decks are mainly
    buoys, misc (rigs, etc...) Why?, is it just to filter out from the
    processing ship data from decks where you do not expect to have them? This
    does not apply here, it is not an error of the metadata per se, we will
    select PT on a deck specific basis, SO THIS IS OBVIOUSLY NOT APPLIED HERE
    - for a set of sid-dck (2), with ship data, numeric id thought to be buoy
    (moored-6 of drifting-7, ?): set to 6,7? which, not really important so far,
    we just want to make sure it is not flagged as a ship....


Reference names of different metadata fields used in the metmetpy modules
and its location column|(section,column) in a data model are
registered in ../properties.py in metadata_datamodels.

If the data model is not available in ./lib or in metadata_models, the module
will return with no output (will break full processing downstream of its
invocation) logging an error.

@author: iregon
"""
import json
import os
from io import StringIO

import pandas as pd

from cdm_reader_mapper.common import functions, logging_hdlr

from .. import properties
from . import library

tool_name = "metmetpy"
module_path = os.path.dirname(os.path.abspath(__file__))
fix_methods_path = os.path.join(module_path, "library")

# functions_module_path = os.path.join(module_path,'correction_functions')
# functions_module_tree = functions_module_path[functions_module_path.find('/' + tool_name + '/')+1:].split('/')
# pt_functions_mdl = importlib.import_module('.'.join(functions_module_tree), package=None)


def correct_it(data, dataset, data_model, deck, pt_col, fix_methods, log_level="INFO"):
    logger = logging_hdlr.init_logger(__name__, level=log_level)

    deck_fix = fix_methods.get(deck)

    if not deck_fix:
        logger.info(
            f"No platform type fixes to apply to deck {deck} \
                    data from dataset {dataset}"
        )
        return data

    #    Find fix method
    if deck_fix.get("method") == "fillna":
        fillvalue = deck_fix.get("fill_value")
        logger.info(f"Filling na values with {fillvalue}")
        data[pt_col] = functions.fill_value(data[pt_col], fillvalue)
        return data
    elif deck_fix.get("method") == "function":
        transform = deck_fix.get("function")
        logger.info(f"Applying fix function {transform}")
        # functions_module_path = os.path.join(fix_methods_path, dataset)
        # functions_module_tree = functions_module_path[
        #    functions_module_path.find("/" + tool_name + "/") + 1 :
        # ].split("/")
        # print(functions_module_tree)
        # pt_functions_mdl = importlib.import_module(
        #    ".".join(functions_module_tree), package=None
        # )
        # trans = getattr(pt_functions_mdl, transform)
        pt_functions_mdl = getattr(library, dataset)
        trans = getattr(pt_functions_mdl, transform)
        return trans(data)
    else:
        logger.error(
            'Platform type fix method "{}" not implemented'.format(
                deck_fix.get("method")
            )
        )
        return


def correct(data, dataset, data_model, deck, log_level="INFO"):
    logger = logging_hdlr.init_logger(__name__, level=log_level)

    fix_file = os.path.join(fix_methods_path, dataset + ".json")
    if not os.path.isfile(fix_file):
        logger.error(f"Dataset {dataset} not included in platform library")
        return
    else:
        with open(fix_file) as fileObj:
            fix_methods = json.load(fileObj)

    pt_col = properties.metadata_datamodels["platform"].get(data_model)

    if not pt_col:
        logger.error(
            f"Data model {data_model} platform column not defined in\
                     properties file"
        )
        return

    if isinstance(data, pd.DataFrame):
        data = correct_it(
            data, dataset, data_model, deck, pt_col, fix_methods, log_level="INFO"
        )
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
            df = correct_it(
                df, dataset, data_model, deck, pt_col, fix_methods, log_level="INFO"
            )
            df.to_csv(buffer, header=False, index=False, mode="a")

        buffer.seek(0)
        return pd.read_csv(buffer, **read_dict)
