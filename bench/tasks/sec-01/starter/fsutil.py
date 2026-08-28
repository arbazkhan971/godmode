"""Path helpers for miniserve."""
import os


def resolve(root, name):
    """Return the path to serve for `name` inside `root`."""
    return os.path.join(root, name)
