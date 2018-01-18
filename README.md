# cc-bandwidth

Ruby script to grab your current Comcast bandwidth usage.

## Pre-requisites

* Docker
* Comcast

## Usage

### Pre-built

```
docker run \
  --env COMCAST_USERNAME=username \
  --env COMCAST_PASSWORD=password \
  atomaka/ccbw
```

### From Source

* Clone repository
* `cp .env.sample .env`
  * Add username and password
* `bin/setup`
* `bin/check`

## Notes

If login fails, login into your account manually via the web one time and
confirm any messages, then retry.
