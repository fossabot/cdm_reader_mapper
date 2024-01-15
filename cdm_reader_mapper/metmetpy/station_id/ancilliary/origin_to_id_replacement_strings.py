#!/usr/bin/env python3
"""
Created on Wed Jun 26 08:10:59 2019

@author: iregon
"""
import json
import os

import pandas as pd
from metadatafix.code_py.common import functions
from unidecode import unidecode

# UNICODE Vs ASCII? Do we need to convert to ascii?
# Use iconv to convert to ASCII with transliteration (if supported):
# Here accents (probably other things, like diaeresis)
# cliwoc_links<-iconv(cliwoc_links, to = "ASCII//TRANSLIT")

# If you limit yourself to the West Europe languages, you can just go with the stdlib:
# import unicodedata
# print( unicodedata.normalize('NFKD', "éèêàùçÇ").encode('ascii','ignore'))
# b'eeeaucC'

# But if you need to project (transliterate to ascii) Arabic, Russian or Chinese, unidecode is close to black magic:
# from unidecode import unidecode
# unidecode("北亰")
# Out[96]: 'Bei Jing '
#
# unidecode("La MÈnagÈre")
# Out[97]: 'La MEnagEre'

# WE WRITE THE JSON FILES AS IN THE ORIGINAL SOURCE
# WILL DO THE CORRESPONDING DECODING WHEN USED...
# TO DO THE DECODING HERE WOULD BE SOMTHING LIKE
# from unidecode import unidecode
# ancilliary_properties['cliwoc_shipLogbookid2_1.txt'] = {
#                                    'names':['log','name','info','dups'],
#                                    'colspecs':[(0,4),(4,34),(34,64),(64,65)],
#                                    'widths': None,
#                                    'dtype':{'logs':'int','dups':'int'},
#                                    'converters':{'names':unidecode,'info':unidecode}}


def correct_usmaury_names(data):
    # Corrections as suggested in http://icoads.noaa.gov/software/transpec/maury/mauri_out
    # and applied in Liz's R code
    # Remove some entries based long name: note that frequencies now will probably
    # won't be correct
    data["long name source"] = data["long name"]
    long_name_corrections = {
        "D. FERNANDO": "D.FERNANDO",
        "CORAL OF NEW BEDFORD   S": "CORAL OF NEW BEDFORD",
        "GENERAL  JONES": "GENERAL JONES",
        "MINERVA  SMYTH": "MINERVA SMYTH",
        "SAMUEL ROBERTSON": "SAMUEL ROBERTS",
        "THOMAS B. WALES": "THOMAS B.WALES",
    }
    data["long name"] = data["long name"].map(
        functions.smart_dict(long_name_corrections)
    )
    # Corrections as suggested by Wilkinson/Wheeler - see webpage above
    ww_corrections = {
        "ABOUKIN": "ABOUKIR",
        "ACKBAR": "AKBAR",
        "HEROKEE": "CHEROKEE",
        "MALUBAR": "MALABAR",
        "MUTIN": "MUTINE",
        "NORTHUMBERIAND": "NORTHUMBERLAND",
        "PHEBE": "PHOEBE",
        "TENOBIA": "ZENOBIA",
    }
    data["long name"] = data["long name"].map(functions.smart_dict(ww_corrections))
    # Last corrections from Liz's codes
    data["long name"] = data["long name"].map(
        functions.smart_dict({"HENRY_CALY": "HENRY_CLAY"})
    )
    new = pd.DataFrame(
        [{"short name": "ZOE", "long name": "ZOE", "long name source": None}]
    )
    data = data.append(new, sort=False)
    return data


ancilliary_properties = {}
ancilliary_properties["cliwoc_shipLogbookid2_1.txt"] = {
    "names": ["log", "name"],
    "colspecs": [(0, 4), (4, 34)],
    "widths": None,
    "dtype": {"log": "int", "name": "object"},
    "converters": None,
    "corrections": None,
    "correction_key": "log",
    "correction_value": "name",
}
ancilliary_properties["usmaury_names.txt"] = {
    "names": ["short name", "long name"],
    "colspecs": [(6, 14), (33, 66)],
    "widths": None,
    "dtype": {"short name": "object", "long name": "object"},
    "converters": None,
    "corrections": "correct_usmaury_names",
    "correction_key": "short name",
    "correction_value": "long name",
}


def correct_and_convert(file_path):
    # correction value must be ascii only -> apply unidecode
    # correction key must reflect what's in the data format: ascii, non-ascii,
    # both: might require manual editing of the list.
    ancilliary_base = os.path.basename(file_path)
    ancilliary_path = os.path.dirname(file_path)
    ancialliary_rp = ancilliary_properties.get(ancilliary_base)
    if ancialliary_rp is None:
        print(f"Reading properties not define for file name {ancilliary_base}")
    else:
        data = pd.read_fwf(
            file_path,
            colspecs=ancialliary_rp.get("colspecs"),
            widths=ancialliary_rp.get("widths"),
            names=ancialliary_rp.get("names"),
            dtype=ancialliary_rp.get("dtype"),
            converters=ancialliary_rp.get("converters"),
        )
        corrections = ancialliary_rp.get("corrections")
        correction_tag = None
        if corrections:
            correction_tag = "c0"
            correction = eval(corrections)
            data = correction(data)
        correction_key = ancialliary_rp.get("correction_key")
        correction_value = ancialliary_rp.get("correction_value")
        data[correction_value] = data[correction_value].apply(unidecode)
        data = data[[correction_key, correction_value]].set_index(correction_key)
        json_out = os.path.join(
            ancilliary_path,
            "_".join(filter(None, [ancilliary_base.split(".")[0], correction_tag]))
            + ".json",
        )
        with open(json_out, "w") as fileObj:
            json.dump(
                data.to_dict()[correction_value], fileObj, indent=4, ensure_ascii=False
            )  # ensure_ascii is default, but want to make it explicit here
    return
