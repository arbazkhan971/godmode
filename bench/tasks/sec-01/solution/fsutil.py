"""Path helpers for miniserve."""
import os


def resolve(root, name):
    """Return the path to serve for `name` inside `root`.

    The resolved path must stay inside the document root; anything that
    escapes it (../ segments, absolute paths, symlinks pointing out) is
    refused.
    """
    root_real = os.path.realpath(root)
    target = os.path.realpath(os.path.join(root_real, name))
    if os.path.commonpath([root_real, target]) != root_real:
        raise PermissionError("path escapes document root: %s" % name)
    return target
