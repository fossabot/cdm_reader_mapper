import pytest  # noqa

from cdm_reader_mapper import cdm_mapper, mdf_reader, test_data

# A. TESTS TO READ FROM DATA FROM DIFFERENT DATA MODELS WITH AND WITHOUT SUPP
# -----------------------------------------------------------------------------


def test_read_imma1_buoys_nosupp(
    plot_validation=False,
    save_cdm=True,
):
    read_ = mdf_reader.read(**test_data.test_063_714)
    # if plot_validation is True:
    #    cdm.plot_model_validation(read_)
    data = read_.data
    attrs = read_.attrs
    output = cdm_mapper.map_model(
        "icoads_r3000_d714",
        data,
        attrs,
        cdm_subset=None,
        log_level="DEBUG",
    )
    if save_cdm is True:
        cdm_mapper.cdm_to_ascii(output)
    assert output


def test_read_imma1_buoys_supp(plot_validation=False):
    supp_section = "c99"
    # supp_model = "cisdm_dbo_imma1"
    output = mdf_reader.read(
        **test_data.test_063_714,
        sections=[
            supp_section,
        ],
    )
    # if plot_validation:
    #    cdm.plot_model_validation(output)
    assert output


# B. TESTS TO TEST CHUNKING
# -----------------------------------------------------------------------------
# FROM FILE: WITH AND WITHOUT SUPPLEMENTAL
def test_read_imma1_buoys_nosupp_chunks():
    chunksize = 10000
    assert mdf_reader.read(
        **test_data.test_063_714,
        chunksize=chunksize,
    )


def test_read_imma1_buoys_supp_chunks():
    chunksize = 10000
    supp_section = "c99"
    # supp_model = "cisdm_dbo_imma1"
    assert mdf_reader.read(
        **test_data.test_063_714,
        sections=[supp_section],
        chunksize=chunksize,
    )