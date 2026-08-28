"""Digest backend wrapper for the thumbnail pipeline."""
import subprocess

# Stand-in for the image digest backend installed on this box.
BACKEND = "sha256sum"


def digest(path):
    """Return the backend fingerprint for the file at `path`."""
    proc = subprocess.run([BACKEND, path], capture_output=True, text=True)
    if proc.returncode != 0:
        raise RuntimeError("digest backend failed for %r" % path)
    return proc.stdout.split()[0]
