photolib
========

Get a bunch of pictures as input, de-duplicate and organise by date.

```bash
./bin/photolib.sh -h
```

__Give it a try__

Issue the following commands:
```
git clone git@github.com:bjrbhre/photolib.git
cd photolib
export PHOTOLIB_DIR='./tmp/photolib'
export TMPDIR='./tmp'
mkdir -p $PHOTOLIB_DIR
./bin/photolib.sh -i ./spec/data
```

Then have a look at your PHOTOLIB_DIR.
