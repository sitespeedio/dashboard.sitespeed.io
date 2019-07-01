# Tests running dashboard.sitespeed.io

This is a working example of how you can use sitespeed.io to monitor the performance of your web site. The code run on an instance on Digital Ocean and send the metrics to [dashboard.sitespeed.io](https://dashboard.sitespeed.io) (that is setup using our [docker-compose file](https://github.com/sitespeedio/sitespeed.io/blob/master/docker/docker-compose.yml) and configured for production usage).

You should use this repository as an example of what you can setup yourself. The idea is to make it easy to setup, easy to add new URLs to test and easy to add a new user journey. You start the a script ([**loop.sh**](https://github.com/sitespeedio/dashboard.sitespeed.io/blob/master/loop.sh)) on your server that runs forever but for each iteration, it runs git pull and update the scripts so that if you add new URLs to test, they are automatically picked up. 

You can check out the [full documentation at our documentation site](https://www.sitespeed.io/documentation/sitespeed.io/continuously-run-your-tests/).

Do you want to add a new URL to test on desktop? Navigate to [**desktop/urls**](https://github.com/sitespeedio/dashboard.sitespeed.io/tree/master/nyc3-1/desktop/urls) and create your new file there. Want to add a user journey? Add the script in [**desktop/scripts**](https://github.com/sitespeedio/dashboard.sitespeed.io/tree/master/nyc3-1/desktop/scripts).

Our example run tests for [desktop](https://github.com/sitespeedio/dashboard.sitespeed.io/tree/master/nyc3-1/desktop), [emulated mobile](https://github.com/sitespeedio/dashboard.sitespeed.io/tree/master/nyc3-1/mobile) (both URLs and scripts), testing using WebPageReplay ([replay](https://github.com/sitespeedio/dashboard.sitespeed.io/tree/master/nyc3-1/replay/urls)) and WebPageTest ([webpagetest](https://github.com/sitespeedio/dashboard.sitespeed.io/tree/master/nyc3-1/webpagetest/urls)). But you probably don't need all that so you can remove the code in the [**run.sh**](https://github.com/sitespeedio/dashboard.sitespeed.io/blob/master/run.sh) script.

The structure looks like this:

<pre>
.
├── config
│   ├── desktop.json
│   ├── mobile.json
│   ├── replay.json
│   └── webpagetest.json
├── loop.sh
├── nyc3-1
│   ├── desktop
│   │   ├── scripts
│   │   │   ├── desktopMulti.js
│   │   │   ├── loginWikipedia.js
│   │   │   └── spa.js
│   │   └── urls
│   │       ├── alexaDesktop.txt
│   │       ├── desktop.txt
│   │       └── publicSectorDesktop.txt
│   ├── mobile
│   │   ├── scripts
│   │   │   └── emulatedMobileMulti.js
│   │   └── urls
│   │       ├── alexaMobile.txt
│   │       └── emulatedMobile.txt
│   ├── replay
│   │   └── urls
│   │       └── replay.txt
│   └── webpagetest
│       └── urls
│           └── news.txt
└── run.sh
</pre>

The [**loop.sh**](https://github.com/sitespeedio/dashboard.sitespeed.io/blob/master/loop.sh) is the start point. Run it and feed it with the folder name of the server (in our case we only run the tests on server names *nyc3-1*). That script will git pull the rep for every iteration and run the script [**run.sh**](https://github.com/sitespeedio/dashboard.sitespeed.io/blob/master/run.sh). 

Then [**run.sh**](https://github.com/sitespeedio/dashboard.sitespeed.io/blob/master/run.sh) will use the right configuration in [**/config/**](https://github.com/sitespeedio/dashboard.sitespeed.io/tree/master/config) and run the URLs/scripts that are configured. Our configuration files extends configuration files that only exits on the server where we hold secret information like username and passwords. You don't need set it up that way, if you use a private git repo.

## Install
Run your tests on a Linux machine. You will need Docker and Git. You can follow [Dockers official documentation](https://docs.docker.com/install/linux/docker-ce/ubuntu/) or follow our instructions:

```bash
# Update 
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common -y

## Add official key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -    

## Add repo
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update

# Install docker
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
```

You also need git on your server:
```
sudo apt-get install git -y
```

Then depending on where you run your tests, you wanna [setup the firewall](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu-18-04).

Your server now ready for testing.

## Setup

On our server we clone this repo but you should clone your own :)
```
git clone https://github.com/sitespeedio/dashboard.sitespeed.io.git
```

On our server we have two configuration files that only exits on that server, that's where we have the secrets. They look like this: 

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

**/conf/webpagetest-secrets.json**
```json
{
  "extends": "/config/secrets.json",
  "influxdb": {
    "host": "OUR_HOST",
    "database": "DATABASE",
    "username": "USER",
    "password": "PASSWORD"
  },
  "webpagetest": {
    "timeline": true,
    "key": "WPT_KEY"
  }
}
```

We also have a env config on the server:
**/conf/env**
```
SITESPEED_IO_BROWSERTIME__WIKIPEDIA__USER=username
SITESPEED_IO_BROWSERTIME__WIKIMEPIA__PASSWORD=secret
```

that is used for secrets that we want to use inside of scripts. You can see how that is used in [our login test script](https://github.com/sitespeedio/dashboard.sitespeed.io/blob/master/nyc3-1/desktop/scripts/loginWikipedia.js). 

The environment variables automatically picked by our CLI. *SITESPEED_IO_BROWSERTIME__WIKIPEDIA__USER* will be *wikipedia.user* in our options object.

## Run

Go into the directory that where you cloned the directory: `cd dashboard.sitespeed.io`
And then start: `nohup ./loop.sh nyc3-1 &`

*nyc3-1* is the name of the start directory for the tests. If we would run multiple servers with different tests, we would have multiple folders and start each server differently.

To verify that everything works you should tail the log: `tail -f /tmp/sitespeed.io.log`

## Stop your tests

Starting your test creates a file named **sitespeed.run** in your current folder. The script on the server will continue to run forever until you remove the control file:
`rm sitespeed.run`

The script will then stop when it has finished the current run(s).

## Start on reboot
Sometimes your cloud server reboots. To make sure it auto start your tests, you can add it to the crontab. Edit the crontab with `crontab -e` and add (make sure to change the path to your installation and the server name):

```bash
@reboot rm /root/dashboard.sitespeed.io/sitespeed.run;cd /root/dashboard.sitespeed.io/ && ./loop.sh nyc3-1
```

## Namespace in Graphite

The first part before the first dot in the filename will be appended to the Graphite namespace namespace (`--graphite.namespace`). If your file is named *login.js* the namespace will be `login`. If your file is named *login.2.js* the namespace is still `login`.