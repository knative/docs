"""Shared helpers for the versions.json manifest written by build.sh."""


def is_version_directory(directory):
    """Return whether a versions.json entry names a single top-level directory."""
    return (isinstance(directory, str) and directory not in ("", ".", "..")
            and "/" not in directory and "\\" not in directory)
