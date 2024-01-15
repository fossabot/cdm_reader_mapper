#!/usr/bin/env python3
"""
Created on Mon Jul 29 08:39:30 2019

@author: iregon
"""
import glob
import json
import os

id_types_path = "/Users/iregon/dessaps/classify_ids/json_files/"

id_patterns = {}

for fileid in glob.glob(os.path.join(id_types_path, "dck*")):
    try:
        with open(fileid) as fileObj:
            mydict = json.load(fileObj)
            id_patterns[mydict.get("dck")] = {}
            id_patterns[mydict.get("dck")]["patterns"] = mydict.get("patterns")
            id_patterns[mydict.get("dck")]["corrections"] = mydict.get("corrections")
            id_patterns[mydict.get("dck")]["notes"] = mydict.get("notes")
    except Exception as e:
        print(e)
        print(fileid)


imma_corrections_path = "/Users/iregon/dessaps/metmetpy/station_id/lib/imma1.json"

with open(imma_corrections_path) as fileObj:
    imma_corrections = json.load(fileObj)


for dck in id_patterns.keys():
    dck = str(dck)
    if dck not in imma_corrections.keys():
        imma_corrections[dck] = {}
    dck_key = None if dck == "None" else int(dck)
    imma_corrections[dck]["patterns"] = id_patterns[dck_key].get("patterns")
    imma_corrections[dck]["corrections"] = id_patterns[dck_key].get("corrections")
    imma_corrections[dck]["notes"] = id_patterns[dck_key].get("notes")


with open(imma_corrections_path, "w") as fileObj:
    json.dump(imma_corrections, fileObj, indent=4)
