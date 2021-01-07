# Configuration files

Here are the configuration files that we use. You can see that they all extends one of two other files. These extra configuration only exits on that server, that's where we have the secrets. They look something like this: 

**/conf/secrets.json**
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

You can follow the same pattern or have another setup if your repo is private.

[Read the documentation on how to configure sitespeed.io](https://www.sitespeed.io/documentation/sitespeed.io/configuration/).