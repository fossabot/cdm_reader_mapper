#!/usr/bin/env python3
"""
Created on Tue Apr  2 10:34:56 2019

Assumes we are never writing a header!

@author: iregon
"""

from io import StringIO

import pandas as pd

from . import logging_hdlr

logger = logging_hdlr.init_logger(__name__, level="DEBUG")

read_params = [
    "chunksize",
    "names",
    "dtype",
    "parse_dates",
    "date_parser",
    "infer_datetime_format",
    "delimiter",
    "quotechar",
    "escapechar",
]


def make_copy(OParser):
    try:
        f = OParser.handles.handle
        NewRef = StringIO(f.getvalue())
        read_dict = {x: OParser.orig_options.get(x) for x in read_params}
        NParser = pd.read_csv(NewRef, **read_dict)
        return NParser
    except Exception:
        logger.error("Failed to copy TextParser", exc_info=True)
        return


def restore(Parser):
    try:
        f = Parser.handles.handle
        f.seek(0)
        read_dict = {x: Parser.orig_options.get(x) for x in read_params}
        Parser = pd.read_csv(f, **read_dict)
        return Parser
    except Exception:
        logger.error("Failed to restore TextParser", exc_info=True)
        return Parser


# def restore(TextParser_ref, TextParser_options):
#    try:
#        TextParser_ref.seek(0)
#        TextParser = pd.read_csv(
#            TextParser_ref,
#            names=TextParser_options["names"],
#            chunksize=TextParser_options["chunksize"],
#            dtype=TextParser_options["dtype"],
#        )  # , skiprows = options['skiprows'])
#        return TextParser
#    except Exception:
#        logger.error("Failed to restore TextParser", exc_info=True)
#        return TextParser


def is_not_empty(Parser):
    try:
        Parser_copy = make_copy(Parser)
    except Exception:
        logger.error(
            f"Failed to process input. Input type is {type(Parser)}", exc_info=True
        )
        return
    try:
        first_chunk = Parser_copy.get_chunk()
        Parser_copy.close()
        if len(first_chunk) > 0:
            logger.debug("Is not empty")
            return True
        else:
            return False
    except Exception:
        logger.debug("Something went wrong", exc_info=True)
        return False


# def is_not_empty(TextParser):
#    try:
#        TextParser_ref = TextParser.handles.handle
#        TextParser_options = TextParser.orig_options
#    except Exception:
#        logger.error(
#            f"Failed to process input. Input type is {type(TextParser)}", exc_info=True
#        )
#        return
#    try:
#        first_chunk = TextParser.get_chunk()
#        TextParser = restore(TextParser_ref, TextParser_options)
#        if len(first_chunk) > 0:
#            logger.debug("Is not empty")
#            return True, TextParser
#        else:
#            return False, TextParser
#    except Exception:
#        return False, TextParser


def get_length(Parser):
    try:
        Parser_copy = make_copy(Parser)
    except Exception:
        logger.error(
            f"Failed to process input. Input type is {type(Parser)}", exc_info=True
        )
        return
    no_records = 0
    for df in Parser_copy:
        no_records += len(df)
    return no_records
