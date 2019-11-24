# get-awx

One liner installer for AWX. Easy and light. 

# Bring up a local awk under docker-compose

Usage:

```bash
  wget -q -O - https://raw.githubusercontent.com/jseguillon/get-awx/master/get-awx.bash | bash
or
  curl -fsSL https://raw.githubusercontent.com/jseguillon/get-awx/master/get-awx.bash | bash
```

Default install dir is "./" ; use AWX_TARGET_DIR for alternative directory. 

# Options

## Release 

Set AWX_RELEASE to choose between different versions:
```bash
AWX_RELEASE=9.0.1; wget -q -O - https://raw.githubusercontent.com/jseguillon/get-awx/master/get-awx.bash | bash
```
 
## Target dir

Set AWX_TARGET_DIR to choose between different versions:
```bash
AWX_TARGET_DIR=9.0.1; wget -q -O - https://raw.githubusercontent.com/jseguillon/get-awx/master/get-awx.bash | bash
```

