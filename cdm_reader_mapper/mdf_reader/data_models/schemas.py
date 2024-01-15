#!/usr/bin/env python3
"""

This module has functions to manage data model
schema files and objects according to the
requirements of the data reader tool

"""

import glob
import json
import logging
import os
import shutil
import sys

from .. import properties

if sys.version_info[0] >= 3:
    py3 = True
else:
    py3 = False


toolPath = os.path.dirname(os.path.abspath(__file__))
schema_lib = os.path.join(toolPath, "library")
templates_path = os.path.join(schema_lib, "templates", "schemas")


def read_schema(schema_name=None, ext_schema_path=None):
    """

    Reads a data model schema file to a dictionary and
    completes it by adding explicitly information the
    reader tool needs

    Keyword Arguments
    -----------------
    schema_name : str, optional
        The name of data model to read. This is for
        data models included in the tool
    ext_schema_path : str, optional
        The path to the external data model schema file


    Either schema_name or ext_schema_path must be provided.


    Returns
    -------
    dict
        Data model schema

    """
    # 1. Validate input
    if schema_name:
        if schema_name not in properties.supported_data_models:
            print(
                f'ERROR: \n\tInput data model "{schema_name}" not supported. See mdf_reader.properties.supported_data_models for supported data models'
            )
            return
        else:
            schema_path = os.path.join(schema_lib, schema_name)
    else:
        schema_path = os.path.abspath(ext_schema_path)
        schema_name = os.path.basename(schema_path)

    schema_file = os.path.join(schema_path, schema_name + ".json")
    if not os.path.isfile(schema_file):
        logging.error(f"Can't find input schema file {schema_file}")
        return

    # 2. Get schema
    with open(schema_file) as fileObj:
        schema = json.load(fileObj)

    # 3. Expand schema
    # Fill in the initial schema to "full complexity": to homogeneize schema,
    # explicitly add info that is implicit to given situations/data models

    # One report per record: make sure later changes are reflected in MULTIPLE
    # REPORTS PER RECORD case below if we ever use it!
    # Currently only supported case: one report per record (line)
    # 3.1. First check for no header case: sequential sections
    if not schema["header"]:
        if not schema["sections"]:
            logging.error(
                f"'sections' block needs to be defined in a schema with no header. Error in data model schema file {schema_file}"
            )
            return
        schema["header"] = dict()

    if not schema["header"].get("multiple_reports_per_line"):
        # 3.2. Make no section formats be internally treated as 1 section format
        if not schema.get("sections"):
            if not schema.get("elements"):
                logging.error(
                    f"Data elements not defined in data model schema file {schema_file} under key 'elements' "
                )
                return
            schema["sections"] = {
                properties.dummy_level: {
                    "header": {},
                    "elements": schema.get("elements"),
                }
            }
            schema["header"]["parsing_order"] = [{"s": [properties.dummy_level]}]
            schema.pop("elements", None)
            schema["sections"][properties.dummy_level]["header"]["delimiter"] = schema[
                "header"
            ].get("delimiter")
            schema["header"].pop("delimiter", None)
            schema["sections"][properties.dummy_level]["header"][
                "field_layout"
            ] = schema["header"].get("field_layout")
            schema["header"].pop("field_layout", None)
        # 3.3. Make parsing order explicit
        if not schema["header"].get("parsing_order"):  # assume sequential
            schema["header"]["parsing_order"] = [{"s": list(schema["sections"].keys())}]
        # 3.4. Make disable_read and field_layout explicit: this is ruled by delimiter being set,
        # unless explicitly set
        for section in schema["sections"].keys():
            if schema["sections"][section]["header"].get("disable_read"):
                continue
            else:
                schema["sections"][section]["header"]["disable_read"] = False
            if not schema["sections"][section]["header"].get("field_layout"):
                delimiter = schema["sections"][section]["header"].get("delimiter")
                schema["sections"][section]["header"]["field_layout"] = (
                    "delimited" if delimiter else "fixed_width"
                )
            for element in schema["sections"][section]["elements"].keys():
                if (
                    schema["sections"][section]["elements"][element].get("column_type")
                    in properties.numpy_integers
                ):
                    np_integer = schema["sections"][section]["elements"][element].get(
                        "column_type"
                    )
                    pd_integer = properties.pandas_nan_integers.get(np_integer)
                    schema["sections"][section]["elements"][element].update(
                        {"column_type": pd_integer}
                    )
        return schema
    else:
        logging.error("Multile reports per line data model: not yet supported")
        return
        # 1X: MULTIPLE REPORTS PER RECORD
        # !!!! NEED TO ADD SECTION LENS TO THE REPORT'S SECTION'S HEADER!!!
        # CAN INFER FROM ELEMENTS LENGHT AND ADD, OR MAKE AS REQUIREMENT TO BE GIVEN
        # global name_report_section
        # Have to assess how the section splitting works when x sequential
        # sections are declared, and only x-y are met.
        # if not schema['header'].get('reports_per_line'):
        #    schema['header']['reports_per_line'] = 24
        # if not schema.get('sections'):
        #    schema['sections'] = dict()
        #    schema['header']['parsing_order'] = [{'s':[]}]
        #    for i in range(1,schema['header']['reports_per_line'] + 1):
        #        schema['sections'].update({str(i):{'header':{},'elements':deepcopy(schema.get('elements'))}})
        # else:
        #    name_report_section = list(schema['sections'].keys())[-1]
        #    schema['header']['name_report_section'] == name_report_section
        #    schema['header']['parsing_order'] = [{'s':list(schema['sections'].keys())[:-1]}]
        #    for i in range(1,schema['header']['reports_per_line'] + 1):
        #        schema['sections'].update({str(i):schema['sections'].get(name_report_section)})
        #    schema['sections'].pop(name_report_section,None)
        # for i in range(1,schema['header']['reports_per_line'] + 1):
        #    schema['header']['parsing_order'][0]['s'].append(str(i))
        # return schema


def df_schema(df_columns, schema):
    """

    Creates a simple attribute dictionary for the elements
    in a dataframe from its data model schema

    Parameters
    ----------
    df_columns : list
        The columns in the data frame (data elements from
        the data model)
    schema : dict
        The data model schema


    Returns
    -------
    dict
        Data elements attributes

    """

    def clean_schema(columns, schema):
        # Could optionally add cleaning of element descriptors that only apply
        # to the initial reading of the data model: field_length, etc....
        for element in list(schema):
            if element not in columns:
                schema.pop(element)
        return

    flat_schema = dict()
    # Flatten main model schema
    for section in schema.get("sections"):
        if section == properties.dummy_level:
            flat_schema.update(schema["sections"].get(section).get("elements"))
        elif schema["sections"].get(section).get("header").get("disable_read"):
            flat_schema.update({(section, section): {"column_type": "object"}})
        else:
            flat_schema.update(
                {
                    (section, x): schema["sections"].get(section).get("elements").get(x)
                    for x in schema["sections"].get(section).get("elements")
                }
            )

    clean_schema(df_columns, flat_schema)

    return flat_schema


def templates():
    """

    Lists the name of the available schema file templates

    Returns
    -------
    list
        Schema file templates alias

    """
    schemas = glob.glob(os.path.join(templates_path, "*.json"))
    return [os.path.basename(x).split(".")[0] for x in schemas]


def copy_template(schema, out_dir=None, out_path=None):
    """

    Copies a schema file template to an output
    file or path

    Parameters
    ----------
    schema : str
        Schema template name to copy

    Keyword Arguments
    -----------------
    out_dir : dict, opt
        Directory to copy schema file template to
    out_path : dict, opt
        Full filename to copy schema file template to

    Either out_dir or out_path must be provided


    """
    schemas = templates()
    if schema in schemas:
        schema_path = os.path.join(templates_path, schema + ".json")
        schema_out = out_path if out_path else os.path.join(out_dir, schema + ".json")
        shutil.copyfile(schema_path, schema_out)
        if os.path.isfile(schema_out):
            print(f"Schema template {schema} copied to {schema_out}")
            return
        else:
            print("copy_template ERROR:")
            print(f"\tError copying schema template {schema} copied to {schema_out}")
            return
    else:
        print("copy_template ERROR:")
        print(f"\tRequested template {schema} must be a valid name.")
        print("\tValid names are: {}".format(", ".join(schemas)))
        return
