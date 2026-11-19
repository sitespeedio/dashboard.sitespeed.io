# Configuration files

Each test file in [tests](../tests) uses the configuration file with the same name here. Most of them extend [desktop.json](desktop.json) or [emulatedMobile.json](emulatedMobile.json), and those extend a file that only exists on the server, where we keep the passwords and keys. The CrUX test extends its own file with the CrUX API key.

**/config/secrets.json** looks something like this:

```json
{
  "graphite": {
    "host": "OUR_HOST",
    "auth": "THE_AUTH",
    "annotationScreenshot": true
  },
  "slack": {
    "hookUrl": "https://hooks.slack.com/services/THE/SECRET/S"
  },
  "resultBaseURL": "https://s3.amazonaws.com/results.sitespeed.io",
  "s3": {
    "key": "S3_KEY",
    "secret": "S3_SECRET",
    "bucketname": "BUCKET_NAME",
    "removeLocalResult": true
  }
}
```

**/config/crux.json** has the Graphite settings and the [CrUX API key](https://www.sitespeed.io/documentation/sitespeed.io/crux/):

```json
{
  "graphite": {
    "host": "OUR_HOST",
    "auth": "THE_AUTH"
  },
  "crux": {
    "key": "YOUR_CRUX_API_KEY"
  }
}
```

You can follow the same pattern or have another setup if your repository is private.

[Read the documentation on how to configure sitespeed.io](https://www.sitespeed.io/documentation/sitespeed.io/configuration/).
