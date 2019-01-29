# rtmp-restreamer
An RTMP streaming server based on nginx to allow for easy distribution to multiple streaming platforms.

## Usage

Run this docker container and expose the RTMP port, eg.

```
docker run -p 1935:1935 donaldpiret/rtmp-restreamer
```

You can then publish to this stream using the following URL:

```
rtmp://[server|localhost]:[port|1935]/live?psk=[secret]
```

The secret can be configured using the RTMP_PUBLISH_KEY ENV var as documented below.

Viewers cam access the stream at:

```
rtmp://[server|localhost]:[port|1935]/live
```

## Configuration

| Env var | Description |
| :--------|:-------------|
| **RTMP_PUBLISH_KEY** | RTMP stream publish secret key |
| **RTMP_FORWARDING_URLS** | Comma-separated list of RTMP streams to forward to. Eg. live-api-s.facebook.com:80/rtmp/secretkey,123.45.67.89:5578/oflaDemo/stream1 |