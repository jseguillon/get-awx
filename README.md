# awx-compose 

Easy and light installer for AWX 


# Bring up a local awk under docker-compose

Usage:

```bash
  wget -q -O - https://raw.githubusercontent.com/jseguillon/get-awx/master/get-awx.bash | bash
or
  curl -fsSL https://raw.githubusercontent.com/jseguillon/get-awx/master/get-awx.bash | bash
```

# Advanced options

Set AWX_RELEASE to choose between different versions:
```bash
export AWX_RELEASE=9.0.1; wget -q -O - https://raw.githubusercontent.com/jseguillon/get-awx/master/get-awx.bash | bash
```

