#!/usr/bin/env python3
"""
Created on Thu May  5 14:04:37 2022

@author: sbiri
"""


import numpy as np

from .. import properties


def deck_717_immt(data):
    # idt=="NNNNN" & dck==700 & sid == 147 & pt == 5
    drifters = "7"
    # sid = "005"
    # pt = "5"
    buoys = "9"
    # regex = re.compile(r"^\d{5,5}$")
    # id_col = properties.metadata_datamodels.get("id").get("immt")
    # sid_col = properties.metadata_datamodels.get("source").get("immt")
    pt_col = properties.metadata_datamodels.get("platform").get("immt")

    data[pt_col].iloc[np.where(data[pt_col].isna())] = drifters
    loc = np.where((np.isnan(data["N"])) & (data[pt_col] == 0))

    data[pt_col].iloc[loc] = buoys

    return data
