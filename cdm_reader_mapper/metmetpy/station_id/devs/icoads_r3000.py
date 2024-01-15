#!/usr/bin/env python3
"""
Created on Tue Jun 25 09:07:05 2019

@author: iregon
"""

import json
import os

from .. import properties

module_path = os.path.dirname(os.path.abspath(__file__))
cor_strings_path = os.path.join(module_path, "correction_maps")


def get_correction_map(cor_map_name):
    cor_map_file = os.path.join(cor_strings_path, cor_map_name + ".json")
    with open(cor_map_file) as fileObj:
        cor_map = json.load(fileObj)
    return cor_map


def deck_116_imma1(data):
    # from Liz's correct_ids.R
    yr_col = properties.metadata_datamodels.get("year").get("imma1")
    id_col = properties.metadata_datamodels.get("id").get("imma1")

    loc = (data[yr_col] == 1953) & (data[id_col] == "404")
    data[id_col].loc[loc] = "4045"

    return data


def deck_187_imma1(data):
    id_col = properties.metadata_datamodels.get("id").get("imma1")

    data[id_col].loc[data[id_col] == "2"] = "0202"
    data[id_col].loc[data[id_col] == "8"] = "0708"

    return data
