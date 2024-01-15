"""
Created on Wed Apr  3 10:31:18 2019

imodel: imma1

Functions to map imodel elements to CDM elements

Main functions are those invoqued in the mappings files (table_name.json)

Main functions need to be part of class mapping_functions()

Main functions get:
    - 1 positional argument (pd.Series or pd.DataFrame with imodel data or
    imodel element name)
    - Optionally, keyword arguments

Main function return: pd.Series, np.array or scalars

Auxiliary functions can be used and defined in or outside class mapping_functions

@author: iregon
"""
import datetime
import math
import uuid

import numpy as np
import pandas as pd
from timezonefinder import TimezoneFinder

icoads_lineage = ". Initial conversion from ICOADS R3.0.0T"
imodel_lineages = {
    "icoads_r3000": icoads_lineage,
    "icoads_r3000_d701_type1": icoads_lineage,
    "icoads_r3000_d701_type2": icoads_lineage,
    "icoads_r3000_d702": icoads_lineage,
    "icoads_r3000_d704": icoads_lineage,
    "icoads_r3000_d705-707": icoads_lineage,
    "icoads_r3000_d714": icoads_lineage + " with supplemental data recovery",
    "icoads_r3000_d721": icoads_lineage,
    "icoads_r3000_d730": icoads_lineage,
    "icoads_r3000_d781": icoads_lineage,
    "icoads_r3000_NRT": ". Initial conversion from ICOADS R3.0.2T NRT",
}

c2k_methods = {
    "gcc_mapping": "method_b",
}

k_elements = {
    "gcc_mapping": 1,
}


def coord_dmh_to_180i(deg, min, hemis):
    """
    Converts longitudes from degrees, minutes and hemisphere
    to decimal degrees between -180 to 180.
    Parameters
    ----------
    deg: longitude or latitude in degrees
    min: logitude or latitude in minutes
    hemis: Hemisphere W or E

    Returns
    var: longitude in decimal degrees
    -------
    """
    hemisphere = 1
    min_df = min / 60
    if hemis.any() == "W":
        hemisphere = -1
    var = np.round((deg + min_df), 2) * hemisphere
    return var


def coord_360_to_180i(long3):
    """
    Converts longitudes from degrees express in 0 to 360
    to decimal degrees between -180 to 180.
    According to
    https://confluence.ecmwf.int/pages/viewpage.action?pageId=149337515
    Parameters
    ----------
    long3: longitude or latitude in degrees

    Returns
    long1: longitude in decimal degrees
    -------
    """
    long1 = (long3 + 180) % 360 - 180

    return long1


def coord_dmh_to_90i(deg, min, hemis):
    """
    Converts latitudes from degrees, minutes and hemisphere
    to decimal degrees between -90 to 90.
    Parameters
    ----------
    deg: longitude or latitude in degrees
    min: logitude or latitude in minutes
    hemis: Hemisphere N or S

    Returns
    var: latitude in decimal degrees
    -------
    """
    hemisphere = 1
    min_df = min / 60
    if hemis == "S":
        hemisphere = -1
    var = np.round((deg + min_df), 2) * hemisphere
    return var


def convert_to_utc_i(date, zone):
    """
    Converts local time zone to utc
    Parameters
    ----------
    date: datetime.series object
    zone: timezone as a string

    Returns
    -------
    date.time_index.obj in utc
    """
    datetime_index_aware = date.tz_localize(tz=zone)
    return datetime_index_aware.tz_convert("UTC")


def time_zone_i(lat, lon):
    tf = TimezoneFinder()
    zone = tf.timezone_at(lng=lon, lat=lat)
    return zone


def longitude_360to180_i(lon):
    if lon > 180:
        return -180 + math.fmod(lon, 180)
    else:
        return lon


def location_accuracy_i(li, lat):
    #    math.sqrt(111**2)=111.0
    #    math.sqrt(2*111**2)=156.97770542341354
    #   Previous implementation:
    #    degrees = {0: .1,1: 1,2: fmiss,3: fmiss,4: 1/60,5: 1/3600,imiss: fmiss}
    degrees = {0: 0.1, 1: 1, 4: 1 / 60, 5: 1 / 3600}
    deg_km = 111
    accuracy = degrees.get(int(li), np.nan) * math.sqrt(
        (deg_km**2) * (1 + math.cos(math.radians(lat)) ** 2)
    )
    return np.nan if np.isnan(accuracy) else max(1, int(round(accuracy)))


def string_add_i(a, b, c, sep):
    if b:
        return sep.join(filter(None, [a, b, c]))
    else:
        return


class mapping_functions:
    def __init__(self, imodel, atts):
        self.imodel = imodel
        self.atts = atts

    def datetime_decimalhour_to_HM(self, ds):
        hours = int(math.floor(ds))
        minutes = int(math.floor(60.0 * math.fmod(ds, 1)))
        return hours, minutes

    def datetime_imma1(self, df):  # TZ awareness?
        date_format = "%Y-%m-%d-%H-%M"
        hours, minutes = np.vectorize(self.datetime_decimalhour_to_HM)(
            df.iloc[:, -1].values
        )
        df.drop(df.columns[len(df.columns) - 1], axis=1, inplace=True)
        df["H"] = hours
        df["M"] = minutes
        # VALUES!!!!
        data = pd.to_datetime(
            df.astype(str).apply("-".join, axis=1).values,
            format=date_format,
            errors="coerce",
        )
        return data

    def datetime_utcnow(self):
        return datetime.datetime.utcnow()

    def datetime_to_cdm_time(self, df):
        """
        Converts year, month, day and time indicator to
        a datetime obj with a 24hrs format '%Y-%m-%d-%H'
        Parameters
        ----------
        dates: list of elements from a date array
        Returns
        -------
        date: datetime obj
        """
        df = df.dropna(how="any")
        date_format = "%Y-%m-%d-%H-%M"

        df_dates = df.core.iloc[:, 0:3]
        df_dates["H"] = 12
        df_dates["M"] = 0
        df_coords = df.core.iloc[:, 3:5]

        # Covert long to -180 to 180 for time zone finding
        df_coords["lon_converted"] = df_coords.apply(
            lambda x: coord_360_to_180i(x["LON"]), axis=1
        )
        df_coords["time_zone"] = df_coords.apply(
            lambda x: time_zone_i(x["LAT"], x["lon_converted"]), axis=1
        )

        data = pd.to_datetime(
            df_dates.iloc[:, 0:5].astype(str).apply("-".join, axis=1).values,
            format=date_format,
            errors="coerce",
        )

        d = {"Dates": data, "Time_zone": df_coords.time_zone.values}
        df_time = pd.DataFrame(data=d)

        df_time["time_utc"] = df_time.apply(
            lambda x: convert_to_utc_i(x["Dates"], x["Time_zone"]), axis=1
        )

        return df_time.time_utc

    def datetime_fix_hour(self, df):
        """
        Converts year, month, day and time indicator to
        a datetime obj with a 24hrs format '%Y-%m-%d-%H'
        Parameters
        ----------
        dates: list of elements from a date array
        Returns
        -------
        date: datetime obj
        """

        date_format = "%Y-%m-%d-%H"
        data = pd.to_datetime(
            df.astype(str).apply("-".join, axis=1).values + "-12",
            format=date_format,
            errors="coerce",
        )

        return data

    def decimal_places(self, element):
        return self.atts.get(element[0]).get("decimal_places")

    def decimal_places_temperature_kelvin(self, element):
        if self.imodel in k_elements.keys():
            k_element = k_elements[self.imodel]
        else:
            k_element = 0
        origin_decimals = self.atts.get(element[k_element]).get("decimal_places")
        if origin_decimals <= 2:
            return 2
        else:
            return origin_decimals

    def decimal_places_pressure_pascal(self, element):
        origin_decimals = self.atts.get(element[0]).get("decimal_places")
        if origin_decimals > 2:
            return origin_decimals - 2
        else:
            return 0

    def df_col_join(self, df, sep):
        joint = df.iloc[:, 0].astype(str)
        for i in range(1, len(df.columns)):
            joint = joint + sep + df.iloc[:, i].astype(str)
        return joint

    def string_opposite(self, ds):
        return "-" + ds

    def float_opposite(self, ds):
        return -ds

    def select_column(self, df):
        c = df.columns.to_list()
        c.reverse()
        s = df[c[0]].copy()
        if len(c) > 1:
            for ci in c[1:]:
                s.update(df[ci])
        return s

    def float_scale(self, ds, factor=1):
        return ds * factor

    def integer_to_float(self, ds, float_type="float32"):
        return ds.astype(float_type)

    def lineage(self, ds):
        strf = datetime.datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
        if self.imodel in imodel_lineages.keys():
            strf = strf + imodel_lineages[self.imodel]
        return strf

    def longitude_360to180(self, ds):
        lon = np.vectorize(longitude_360to180_i)(ds)
        return lon

    def location_accuracy(self, df):  # (li_core,lat_core) math.radians(lat_core)
        la = np.vectorize(location_accuracy_i, otypes="f")(
            df.iloc[:, 0], df.iloc[:, 1]
        )  # last minute tweak so that is does no fail on nans!
        return la

    def observing_programme(self, ds):
        op = {str(i): [5, 7, 56] for i in range(0, 6)}
        op.update({"7": [5, 7, 9]})
        return ds.map(op, na_action="ignore")

    def string_add(
        self, ds, prepend="", append="", separator="", zfill_col=None, zfill=None
    ):
        if zfill_col and zfill:
            for col, width in zip(zfill_col, zfill):
                ds.iloc[:, col] = ds.iloc[:, col].astype(str).str.zfill(width)
        ds["string_add"] = np.vectorize(string_add_i)(prepend, ds, append, separator)
        return ds["string_add"]

    def string_join_add(
        self, df, prepend=None, append=None, separator="", zfill_col=None, zfill=None
    ):
        # This duplication is to prevent error in Int to object casting of types
        # when nrows ==1, shown after introduction of nullable integers in objects.
        duplicated = False
        if len(df) == 1:
            df = pd.concat([df, df])
            duplicated = True
        if zfill_col and zfill:
            for col, width in zip(zfill_col, zfill):
                df.iloc[:, col] = df.iloc[:, col].astype(str).str.zfill(width)
        joint = self.df_col_join(df, separator)
        df["string_add"] = np.vectorize(string_add_i)(prepend, joint, append, separator)
        if duplicated:
            df = df[:-1]
        return df["string_add"]

    def apply_sign(self, ds):
        ds.iloc[0] = np.where((ds.iloc[0] == 0) | (ds.iloc[0] == 5), 1, -1)
        return ds

    def temperature_celsius_to_kelvin(self, ds):
        if self.imodel in c2k_methods.keys():
            method = c2k_methods[self.imodel]
        else:
            method = "method_a"
        if method == "method_a":
            return ds + 273.15
        if method == "method_b":
            ds.iloc[:, 0] = np.where((ds.iloc[:, 0] == 0) | (ds.iloc[:, 0] == 5), 1, -1)
            # print(ds.iloc[:, 0]*ds.iloc[:, 1])
            return ds.iloc[:, 0] * ds.iloc[:, 1] + 273.15

    def time_accuracy(self, ds):  # ti_core
        # Shouldn't we use the code_table mapping for this? see CDM!
        secs = {
            "0": 3600,
            "1": int(round(3600 / 10)),
            "2": int(round(3600 / 60)),
            "3": int(round(3600 / 100)),
        }
        return ds.map(secs, na_action="ignore")

    def guid(self, df, prepend="", append=""):
        df["YR"] = df["YR"].apply(lambda x: f"{x:04d}")
        df["MO"] = df["MO"].apply(lambda x: f"{x:02d}")
        df["DY"] = df["DY"].apply(lambda x: f"{x:02d}")
        df["GG"] = df["GG"].astype("int64").apply(lambda x: f"{x:02d}")
        name = df.apply(lambda x: "".join(x), axis=1)
        uid = np.empty(np.shape(df["YR"]), dtype="U126")
        for i, n in enumerate(name):
            uid[i] = (
                str(prepend) + uuid.uuid5(uuid.NAMESPACE_OID, str(n)).hex + str(append)
            )
        df["UUID"] = uid
        return df["UUID"]
