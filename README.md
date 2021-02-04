# Tests running dashboard.sitespeed.io

[![Build status][travis-image]][travis-url]

This is a working example of how you can use sitespeed.io to monitor the performance of your web site. The code run on an instance on Digital Ocean and send the metrics to [dashboard.sitespeed.io](https://dashboard.sitespeed.io) (that is setup using our [docker-compose file](https://github.com/sitespeedio/sitespeed.io/blob/main/docker/docker-compose.yml) and configured for production usage).

You should use this repository as an example of what you can setup yourself. The idea is to make it easy to setup, easy to add new URLs to test and easy to add a new user journey. You start the a script ([**loop.sh**](https://github.com/sitespeedio/dashboard.sitespeed.io/blob/main/loop.sh)) on your server that runs forever but for each iteration, it runs git pull and update the scripts so that if you add new URLs to test, they are automatically picked up.

You can check out the [full documentation at our documentation site](https://www.sitespeed.io/documentation/sitespeed.io/continuously-run-your-tests/).

Do you want to add a new URL to test on desktop? Navigate to [**desktop**](https://github.com/sitespeedio/dashboard.sitespeed.io/tree/main/tests/desktop) and create your new file there. Want to add a user journey? Add the script in the same place and name then *.js*.

Our example run tests for [desktop](https://github.com/sitespeedio/dashboard.sitespeed.io/tree/main/tests/desktop), [emulated mobile](https://github.com/sitespeedio/dashboard.sitespeed.io/tree/main/tests/emulatedMobile) (both URLs and scripts).

The structure looks like this:

<pre>
.
├── README.md
├── config
│   ├── README.md
│   ├── alexaDesktop.json
│   ├── alexaMobile.json
│   ├── crux.json
│   ├── desktop.json
│   ├── desktopMulti.json
│   ├── emulatedMobile.json
│   ├── emulatedMobileMulti.json
│   ├── loginWikipedia.json
│   ├── news.json
│   ├── replay.json
│   └── spa.json
├── loop.sh
├── run.sh
└── tests
    ├── desktop
    │   ├── alexaDesktop.txt
    │   ├── crux.txt
    │   ├── desktop.txt
    │   ├── desktopMulti.js
    │   ├── loginWikipedia.js
    │   ├── news.txt
    │   ├── replay.replay
    │   └── spa.js
    └── emulatedMobile
        ├── alexaMobile.txt
        ├── emulatedMobile.txt
        └── emulatedMobileMulti.js
        
</pre>

The [**loop.sh**](https://github.com/sitespeedio/dashboard.sitespeed.io/blob/main/loop.sh) is the start point. Run it. That script will git pull the repo for every iteration and run the script [**run.sh**](https://github.com/sitespeedio/dashboard.sitespeed.io/blob/main/run.sh).

Then [**run.sh**](https://github.com/sitespeedio/dashboard.sitespeed.io/blob/main/run.sh) will use the right configuration in [**/config/**](https://github.com/sitespeedio/dashboard.sitespeed.io/tree/main/config) and run the URLs/scripts that are configured. Our configuration files extends configuration files that only exits on the server where we hold secret information like username and passwords. You don't need set it up that way, if you use a private git repo.

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
  },
  "browsertime": {
    "wikipedia": {
      "user": "username",
      "password": "password"
    }
  }

}
```

## Run

Go into the directory that where you cloned the directory: `cd dashboard.sitespeed.io`
And then start: `nohup ./loop.sh &`

To verify that everything works you should tail the log: `tail -f /tmp/sitespeed.io.log`

## Stop your tests

Starting your test creates a file named **sitespeed.run** in your current folder. The script on the server will continue to run forever until you remove the control file:
`rm sitespeed.run`

The script will then stop when it has finished the current run(s).

## Start on reboot
Sometimes your cloud server reboots. To make sure it auto start your tests, you can add it to the crontab. Edit the crontab with `crontab -e` and add (make sure to change the path to your installation and the server name):

```bash
@reboot rm /root/dashboard.sitespeed.io/sitespeed.run;cd /root/dashboard.sitespeed.io/ && ./loop.sh
```

[travis-image]: https://img.shields.io/travis/sitespeedio/dashboard.sitespeed.io.svg?style=flat-square
[travis-url]: https://travis-ci.org/sitespeedio/dashboard.sitespeed.io
