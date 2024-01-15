#!/usr/bin/env python3
"""
Created on Wed Jul  3 09:48:18 2019

@author: iregon
"""

import numpy as np
import pandas as pd

from cdm_reader_mapper.common import pandas_TextParser_hdlr


def count_by_cat_i(serie):
    counts = serie.value_counts(dropna=False)
    counts.index.fillna(str(np.nan))
    return counts.to_dict()


def get_length(data):
    if not isinstance(data, pd.io.parsers.TextFileReader):
        return len(data)
    else:
        return pandas_TextParser_hdlr.get_length(data)

    return


def count_by_cat(data, col):
    if not isinstance(data, pd.io.parsers.TextFileReader):
        return count_by_cat_i(data[col])
    else:
        data_cp = pandas_TextParser_hdlr.make_copy(data)
        count_dicts = []
        for df in data_cp:
            count_dicts.append(count_by_cat_i(df[col]))

        data_cp.close()
        cats = [list(x.keys()) for x in count_dicts]
        cats = list({x for y in cats for x in y})
        cats.sort
        count_dict = {}
        for cat in cats:
            count_dict[cat] = sum([x.get(cat) for x in count_dicts if x.get(cat)])
        return count_dict

    return
