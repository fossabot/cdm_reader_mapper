#!/usr/bin/env python3
"""
Created on Tue Jun 25 09:00:19 2019

Validates the datetime fields of a data model:
    -1. extracts or creates the datetime field of a data model as defined
    in submodule model_datetimes.
    -2. validates to False where NaT: no datetime or conversion to datetime failure

Validation is data model specific.

Output is a boolean series.

Does not account for input dataframes/series stored in TextParsers: as opposed
to correction modules, the output is only a boolean series which is external
to the input data ....

If the datetime conversion (or extraction) for a given data model is not
available in submodule model_datetimes, the module
will return with no output (will break full processing downstream of its
invocation) logging an error.

Reference names of different metadata fields used in the metmetpy modules
and its location column|(section,column) in a data model are
registered in ../properties.py in metadata_datamodels.

NaN, NaT: will validate to False.

@author: iregon
"""
import os

import pandas as pd

from cdm_reader_mapper.common import logging_hdlr

from . import model_datetimes


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


def validate(data, data_model, dck, log_level="INFO"):
    # dck input only to be consistent with other validators in the metmetpy module
    logger = logging_hdlr.init_logger(__name__, level=log_level)

    if not isinstance(data, pd.DataFrame) and not isinstance(data, pd.Series):
        logger.error(
            f"Input data must be a pd.DataFrame or pd.Series.\
                     Input data type is {type(data)}"
        )
        return

    data_model_datetime = model_datetimes.to_datetime(data, data_model)

    if not isinstance(data_model_datetime, pd.Series):
        logger.error(
            'Data model "{0}" datetime conversor not defined in model_datetimes module "{0}"'.format(
                data_model
            )
        )
        return
    else:
        return data_model_datetime.notna()
