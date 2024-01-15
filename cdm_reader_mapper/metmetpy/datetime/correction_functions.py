#!/usr/bin/env python3
"""
Created on Tue Jun 25 09:07:05 2019

@author: iregon
"""

import os

import pandas as pd

from .. import properties
from . import model_datetimes

module_path = os.path.dirname(os.path.abspath(__file__))
cor_strings_path = os.path.join(module_path, "correction_maps")


def dck_201_imma1(data):
    yr_col = properties.metadata_datamodels.get("year").get("imma1")
    mo_col = properties.metadata_datamodels.get("month").get("imma1")
    dd_col = properties.metadata_datamodels.get("day").get("imma1")
    hr_col = properties.metadata_datamodels.get("hour").get("imma1")

    datetime_cols = [yr_col, mo_col, dd_col, hr_col]
    loc = (data[yr_col] <= 1899) & (data[hr_col] == 0)

    if len(data.loc[loc]) > 0:
        datetime_ = model_datetimes.to_datetime(data, "imma1")
        datetime_[loc] = datetime_[loc] + pd.DateOffset(days=-1)
        data[datetime_cols] = model_datetimes.from_datetime(datetime_)
        return data
    else:
        return data
