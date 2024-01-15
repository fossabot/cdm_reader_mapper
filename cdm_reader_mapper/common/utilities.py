try:
    from importlib.resources import files as _files
except ImportError:
    from importlib_resources import files as _files


def get_files(anchor):
    return _files(anchor)
