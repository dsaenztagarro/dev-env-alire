## dev-env-alire

### Running tests

```bash
alr printenv | grep GNAT_NATIVE_ALIRE_PREFIX|GPRBUILD_ALIRE_PREFIX
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
