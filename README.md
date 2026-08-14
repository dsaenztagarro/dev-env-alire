## dev-env-alire

Docker dev environment for Ada/SPARK via [Alire](https://alire.ada.dev), built `FROM` the base image [`dev-env`](../dev-env-dockerfile).
It runs as the `me` user with your project bind-mounted at `/workspace` (see the base image's README for the identity/workspace convention).

### The `alr` toolchain

`alr` is **pinned to a stable release** (`ALR_VERSION`, default `2.1.1`) and fetched at build time with a verified SHA-256 — native `aarch64-linux` binaries have shipped in Alire's versioned releases since [PR #1832](https://github.com/alire-project/alire/pull/1832), so there is no longer any need to vendor a nightly build.
`ADD --checksum` layer-caches the download by URL + checksum, so it is fetched once per version bump, not on every build.

To upgrade `alr`, change **both** `ARG ALR_VERSION` and the `ADD --checksum` hash in the [`Dockerfile`](Dockerfile), taking the new values from the [releases page](https://github.com/alire-project/alire/releases).
The Ada Language Server has no upstream `aarch64` release to pin yet, so it stays vendored under `third_party/`.

### Build & run

From the repo root (needs Docker with BuildKit — the default in Docker Desktop):

```bash
make image      # build dsaenztagarro/dev-env-alire
make start      # run it detached, mounting ~/Code/alire at /workspace
make terminal   # open a shell in the running container
make stop       # stop and remove it
```

### Running tests

```bash
alr printenv | grep "GNAT_NATIVE_ALIRE_PREFIX\|GPRBUILD_ALIRE_PREFIX"
export PATH="<gnat_native_dir>/bin:<gprbuild_dir>/bin:$PATH"

# Use Built-in venv (Python 3.3+)
# Create virtualenv
python -m venv myenv

# Activate virtualenv
source myenv/bin/activate

# Install e3-testsuite and all its dependencies
$ pip install -r requirements.txt

# Run tests
python3 run.py
```
