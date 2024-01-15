from . import cdm_mapper  # noqa
from . import mdf_reader  # noqa
from . import metmetpy  # noqa
from . import operations  # noqa
from .data import test_data  # noqa


def _get_version():
    __version__ = "unknown"
    try:
        from ._version import __version__
    except ImportError:
        pass
    return __version__


__version__ = _get_version()
