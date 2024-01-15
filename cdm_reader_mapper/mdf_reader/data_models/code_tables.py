#!/usr/bin/env python3
"""

This module has functions to manage data model
code table files and objects according to the
requirements of the data reader tool

"""

import datetime
import glob
import json
import os
import shutil
from copy import deepcopy

import numpy as np
import pandas as pd

try:
    from pandas.io.json._normalize import nested_to_record
except Exception:
    from pandas.io.json.normalize import nested_to_record
import ast

# https://stackoverflow.com/questions/10756427/loop-through-all-nested-dictionary-values
# def print_nested(d):
#    if isinstance(d, dict):
#        for k, v in d.items():
#            print_nested(v)
#    elif hasattr(d, '__iter__') and not isinstance(d, str):
#        for item in d:
#            print_nested(item)
#    elif isinstance(d, str):
#        print(d)
#
#    else:
#        print(d)

toolPath = os.path.dirname(os.path.abspath(__file__))
table_lib = os.path.join(toolPath, "lib")
templates_path = os.path.join(table_lib, "templates", "code_tables")


def read_table(table_path):
    """

    Reads a data model code table file to a dictionary.
    It completes the code table to the full complexity
    the data reader expects, by appending information
    on secondary keys and expanding range keys.

    Arguments
    ---------
    table_path : str
        The file path of the code table.

    Returns
    -------
    dict
        Code table

    """

    with open(table_path) as fileObj:
        table = json.load(fileObj)
    # Add keys for nested code tables
    keys_path = ".".join([".".join(table_path.split(".")[:-1]), "keys"])
    if os.path.isfile(keys_path):
        with open(keys_path) as fileObj:
            table_keys = json.load(fileObj)
            table["_keys"] = {}
            for x, y in table_keys.items():
                key = eval_dict_items(x)
                values = [eval_dict_items(k) for k in y]
                table["_keys"][key] = values
    # Expand range keys
    expand_integer_range_key(table)

    return table


def templates():
    """

    Lists the name of the available code table templates

    Returns
    -------
    list
        Code table template aliases

    """

    tables = glob.glob(os.path.join(templates_path, "*.json"))
    return [os.path.basename(x).split(".")[0] for x in tables]


def copy_template(table, out_dir=None, out_path=None):
    """

    Copies a code table template to an output
    file or path

    Parameters
    ----------
    table : str
        Code table template name to copy

    Keyword Arguments
    -----------------
    out_dir : dict, opt
        Directory to copy code table file template to
    out_path : dict, opt
        Full filename to copy code table file template to

    Either out_dir or out_path must be provided


    """

    tables = templates()
    if table in tables:
        table_path = os.path.join(templates_path, table + ".json")
        table_out = out_path if out_path else os.path.join(out_dir, table + ".json")
        shutil.copyfile(table_path, table_out)
        if os.path.isfile(table_out):
            print(f"Schema template {table} copied to {table_out}")
            return
        else:
            print("copy_template ERROR:")
            print(f"\tError copying table template {table} copied to {table_out}")
            return
    else:
        print("copy_template ERROR:")
        print(f"\tRequested template {table} must be a valid name.")
        print("\tValid names are: {}".format(", ".join(tables)))
        return


def expand_integer_range_key(d):
    # Looping based on print_nested above
    if isinstance(d, dict):
        for k, v in list(d.items()):
            if "range_key" in k[0:9]:
                range_params = k[10:-1].split(",")
                try:
                    lower = int(range_params[0])
                except Exception as e:
                    print("Lower bound parsing error in range key: ", k)
                    print("Error is:")
                    print(e)
                    return
                try:
                    upper = int(range_params[1])
                except Exception as e:
                    if range_params[1] == "yyyy":
                        upper = datetime.date.today().year
                    else:
                        print("Upper bound parsing error in range key: ", k)
                        print("Error is:")
                        print(e)
                        return
                if len(range_params) > 2:
                    try:
                        step = int(range_params[2])
                    except Exception as e:
                        print("Range step parsing error in range key: ", k)
                        print("Error is:")
                        print(e)
                        return
                else:
                    step = 1
                for i_range in range(lower, upper + 1, step):
                    deep_copy_value = deepcopy(
                        d[k]
                    )  # Otherwiserepetitions are linked and act as one!
                    d.update({str(i_range): deep_copy_value})
                d.pop(k, None)
            else:
                for k, v in d.items():
                    expand_integer_range_key(v)


def eval_dict_items(item):
    try:
        return ast.literal_eval(item)
    except Exception:
        return item


def table_keys(table):
    separator = "∿"  # something hopefully not in keys...
    if table.get("_keys"):
        _table = deepcopy(table)
        _table.pop("_keys")
        keys = list(nested_to_record(_table, sep=separator).keys())

        return [x.split(separator) for x in keys]
    else:
        return list(table.keys())


def get_nested(table, *args):
    # HERE HAVE TO ADD WHICH ITEM TO GET FROM THE KEY: WE HAVE TO ADD VALUE, LOWER, ETC...TO THE CODE TABLES!!!
    # CAN BE AND OPTIONAL PARAMETER, LIKE: similarly, would have to add tbis to table_value_from_keys
    #    def get_nested(table,param = None,*args):
    #       nested_get_str = 'table'
    #       z = np.array([*args])
    #       for i,x in enumerate(z):
    #           nested_get_str += '.get(z[' + str(i) + '])'
    #       if param:
    #           nested_get_str += '.get(' + param + ')'
    #       try:
    #           return eval(nested_get_str)
    #       except:
    #           return None
    nested_get_str = "table"
    z = np.array([*args])
    for i, x in enumerate(z):
        nested_get_str += ".get(z[" + str(i) + "])"
    try:
        return eval(nested_get_str)
    except Exception:
        return None


def table_value_from_keys(table, df):
    # df is pd.DataFrame or Series
    v_nested_get = np.vectorize(
        get_nested
    )  # Because cannot directly vectorize a nested get, we build it in a function, and then vectorize it
    calling_str = "v_nested_get(table"
    if isinstance(df, pd.DataFrame):
        # return v_nested_get(table,[ df[x]  for x in df]) # This won't work
        for i, x in enumerate(df.columns):
            calling_str += (
                ",df[" + str(x) + "].astype(str)"
            )  # have to do likewise in not DataFrame!!!
        calling_str += ")"
        return eval(calling_str)
    else:
        return v_nested_get(table, df)
