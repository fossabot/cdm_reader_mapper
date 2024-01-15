#!/usr/bin/env python3
"""
Created on Thu Apr 11 13:45:38 2019

Look into validation results

Need to type:

    %matplotlib auto

if ipython and want to get the interactive plots!


@author: iregon
"""

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

from .. import properties


# ------------------------------------------------------------------------------
def plot_numeric_validation(data, mask, element, valid_max, valid_min, units):
    bbox_props = dict(boxstyle="round", fc="w", ec="0.5", alpha=0.9)
    plt.figure()
    ax = data.plot(label="data")
    # Carefull, something may not be working here in the no data tag!!!
    no_data = True if len(data.loc[data.notna()]) == 0 else False
    data.where(~mask).plot(marker="o", color="r", ax=ax, label="not valid")
    true_value = data.where(mask).median()
    if not true_value or np.isnan(true_value):
        if valid_max is not None and valid_min is not None:
            true_value = valid_min + (valid_max - valid_min) / 2.0
        else:
            true_value = 1
    falses = pd.Series(index=data.index, data=true_value)
    falses.where(~mask & data.isna()).plot(
        marker="o", color="r", ax=ax, label="_nolegend_"
    )
    trues = pd.Series(index=data.index, data=true_value)
    trues.where(mask).plot(color="YellowGreen", ax=ax, label="valid")
    if valid_max is not None and valid_min is not None:
        ax.fill_between(
            data.index,
            valid_min,
            valid_max,
            facecolor="DarkSlateGrey",
            alpha=0.25,
            interpolate=False,
            label="valid range",
            zorder=5,
        )
    ax.grid(linestyle=":", which="major", color="grey")
    if units:
        ax.set_ylabel(units, fontsize=10)
    ax.set_xlabel("idx")
    if no_data:
        ax.text(
            (ax.get_xlim()[1] - ax.get_xlim()[0]) / 2,
            ax.get_ylim()[0] + (ax.get_ylim()[1] - ax.get_ylim()[0]) / 2,
            "no data",
            ha="center",
            va="center",
            size=20,
            bbox=bbox_props,
        )
    plt.legend()
    plt.title(element + " validation")
    plt.show()


def plot_categorical_validation(data, mask, element, codetable):
    merged = pd.concat([data, mask], axis=1)
    merged.columns = ["data", "mask"]
    counts = pd.DataFrame(
        index=merged["data"].value_counts(dropna=False).sort_index().index
    )
    counts["Data"] = merged["data"].value_counts(dropna=False).sort_index()
    # Watch here, need to convert to str so that NaNs are not removed from the grouping!
    # Could be dangerous if we are not just counting, but then, we would not need the NaNs...
    counts.index = counts.index.fillna(str(np.nan))
    counts["Not valid"] = (
        merged.astype(str).query('mask == "False"').groupby("data").count()
    )
    counts["Valid"] = merged.astype(str).query('mask == "True"').groupby("data").count()
    fig = plt.figure()  # Create matplotlib figure
    ax = fig.add_subplot(111)  # Create matplotlib axes
    ax2 = ax.twinx()  # Create another axes that shares the same x-axis as ax.
    width = 0.4
    counts["Data"].plot(
        kind="bar",
        ax=ax,
        width=width,
        position=1,
        color="DarkCyan",
        label="data counts",
    )
    counts[["Not valid", "Valid"]].plot(
        kind="bar",
        stacked=True,
        ax=ax2,
        width=width,
        position=0,
        legend=False,
        color=["DarkRed", "YellowGreen"],
    )
    ax.set_yscale("log")
    ax.set_ylabel("data counts", fontsize=10)
    ax2.set_yscale("log")
    ax2.set_ylabel("validation counts", fontsize=10)
    ax.legend(loc=2)
    ax2.legend()
    ax.grid(linestyle=":", which="major", color="grey")
    plt.title(element + " validation \n Codetable: " + codetable)
    ax.set_xlim(-1, len(counts))
    ax.set_xlabel("code")
    ax2.set_xlim(-1, len(counts))
    ax.set_ylim(0.5, ax.get_ylim()[1])
    ax2.set_ylim(0.5, ax2.get_ylim()[1])
    plt.show()


# ------------------------------------------------------------------------------


def plot_model_validation(imodel):
    for element in imodel.atts.keys():
        title_element = (
            element
            if not isinstance(element, tuple)
            else element[1] + " (" + element[0] + ")"
        )
        dtype = imodel.atts.get(element).get("column_type")
        if dtype in properties.numeric_types:
            valid_max = imodel.atts.get(element).get("valid_max")
            valid_min = imodel.atts.get(element).get("valid_min")
            units = imodel.atts.get(element).get("units")
            plot_numeric_validation(
                imodel.data[element],
                imodel.mask[element],
                title_element,
                valid_max,
                valid_min,
                units,
            )
        elif dtype == "key":
            # ...mmm should account for multi-keyed combinations
            codetable = imodel.atts.get(element).get("codetable")
            if not codetable:
                codetable = "undefined"
            plot_categorical_validation(
                imodel.data[element],
                imodel.mask[element],
                title_element,
                codetable,
            )
