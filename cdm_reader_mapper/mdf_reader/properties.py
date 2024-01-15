import glob
import os

from ..properties import (  # noqa
    numeric_types,
    numpy_integers,
    object_types,
    pandas_nan_integers,
)

schema_path = os.path.join(os.path.dirname(__file__), "data_models", "library")
supported_data_models = []
for x in glob.glob(schema_path + "/*/*.json"):
    bname = os.path.basename(x).split(".")[0]
    uname = os.path.dirname(x).split("/")[-1]
    wname = os.path.dirname(x).split("\\")[-1]
    if (bname == uname) or (bname == wname):
        supported_data_models += [bname]

pandas_dtypes = {}
for dtype in object_types:
    pandas_dtypes[dtype] = "object"
pandas_dtypes.update({x: x for x in numeric_types})

# ....and how they are managed
data_type_conversion_args = {}
for dtype in numeric_types:
    data_type_conversion_args[dtype] = ["scale", "offset"]
data_type_conversion_args["str"] = ["disable_white_strip"]
data_type_conversion_args["object"] = ["disable_white_strip"]
data_type_conversion_args["key"] = ["disable_white_strip"]
data_type_conversion_args["datetime"] = ["datetime_format"]

# Misc ------------------------------------------------------------------------
tol = 1e-10
dummy_level = "_SECTION_"
# Length of reports in initial read
MAX_FULL_REPORT_WIDTH = 100000
# This is a delimiter internally used when writing to buffers
# It is the Unicode Character 'END OF TEXT'
# It is supposed to be safe because we don;t expect it in a string
# It's UTF-8 encoding lenght is not > 1, so it is supported by pandas 'c'
# engine, which is faster than the python engine.
internal_delimiter = "\u0003"
