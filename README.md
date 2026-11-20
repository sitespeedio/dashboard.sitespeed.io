# Tests running dashboard.sitespeed.io

[![Lint](https://github.com/sitespeedio/dashboard.sitespeed.io/actions/workflows/lint.yml/badge.svg)](https://github.com/sitespeedio/dashboard.sitespeed.io/actions/workflows/lint.yml)

This is a working example of how you can use sitespeed.io to monitor the performance of your web site. The tests run on a server at Hetzner and send the metrics to [dashboard.sitespeed.io](https://dashboard.sitespeed.io). That server uses our [docker-compose file](https://github.com/sitespeedio/sitespeed.io/blob/main/docker/docker-compose.yml), and its Grafana provisions the dashboards from [the sitespeed.io repository](https://github.com/sitespeedio/sitespeed.io/tree/main/docker/grafana/provisioning), so a dashboard change that is merged there shows up on the demo.

Use this repository as an example of what you can set up yourself. The idea is to make it easy to add new URLs to test and new user journeys. You start a script ([**loop.sh**](loop.sh)) on your server that runs forever. For each iteration it runs `git pull`, so new URLs and scripts are picked up automatically.

Read the [full documentation](https://www.sitespeed.io/documentation/sitespeed.io/continuously-run-your-tests/) for how it works.

## What we test and where the data goes

| Test | Browsers | Sends to | Dashboards |
|---|---|---|---|
| [tests/docker/desktop](tests/docker/desktop) (URLs and user journeys) | Chrome, Firefox | Graphite | Page metrics, Leaderboard, User journey |
| [tests/docker/emulatedMobile](tests/docker/emulatedMobile) | Chrome | Graphite | Page metrics, Leaderboard, User journey |
| [tests/desktop](tests/desktop) (sitespeed.io installed on the server, not in Docker) | Chrome, Firefox, Edge | Graphite | Page metrics, Leaderboard |
| [tests/docker/webpagereplay](tests/docker/webpagereplay) ([WebPageReplay](https://www.sitespeed.io/documentation/sitespeed.io/webpagereplay/)) | Chrome, Firefox | Graphite, OpenSearch (also every run), and the [compare plugin](https://www.sitespeed.io/documentation/sitespeed.io/compare/) | Page metrics (Regressions tab), OpenSearch |
| [tests/docker/desktop/crux.txt](tests/docker/desktop/crux.txt) | No browser, only the Chrome User Experience Report API | Graphite | Chrome User Experience Report |

The WebPageReplay test runs 21 iterations and compares each test with a baseline using a Mann-Whitney U test that looks for regressions. [run.sh](run.sh) saves a new baseline on Sundays (`--compare.saveBaseline`), so the rest of the week is compared with the last Sunday test. WebPageReplay replays the same recorded responses every time, so a significant change there comes from the browser or the page code, not from the network. The baselines are saved as JSON files in the folder where the tests run.

## How it is organised

```
.
├── config                  # One configuration file for each test file
├── loop.sh                 # Runs forever: git pull, then run.sh
├── run.sh                  # Runs every test in each folder in a set of browsers
└── tests
    ├── desktop             # Runs sitespeed.io installed on the server
    └── docker
        ├── desktop
        ├── emulatedMobile
        └── webpagereplay
```

Each test file needs a configuration file with the same name in [config](config): *tests/docker/desktop/desktop.txt* uses *config/desktop.json*. A *.txt* file is a list of URLs and a *.js* file is a user journey script. To add a test, add the file and its configuration file and push.

The configuration files extend files that only exist on the server, where we keep passwords and keys. See [config/README.md](config/README.md). You do not need that setup if your repository is private.

## Install
Run your tests on a Linux machine. You need Docker and Git. Follow [Docker's documentation](https://docs.docker.com/engine/install/ubuntu/), or on Ubuntu:

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl git -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
```

The tests in [tests/desktop](tests/desktop) run sitespeed.io without Docker, so they also need Node.js, sitespeed.io (`npm install -g sitespeed.io`) and the browsers on the server. Skip that folder if you only want Docker.

Then [set up the firewall](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu). On the server that runs Graphite, OpenSearch and Grafana, only let the test server reach Graphite (port 2003) and OpenSearch (port 9200): both accept data from anyone who can reach them.

## Run

```bash
git clone https://github.com/sitespeedio/dashboard.sitespeed.io.git
cd dashboard.sitespeed.io
sudo mkdir -p /var/log/sitespeed.io
nohup ./loop.sh &
```

Clone your own repository instead of ours :) To check that everything works, follow the log: `tail -f /var/log/sitespeed.io/sitespeed.io.log`

## Stop your tests

When the tests start, they create a file named **sitespeed.run** in the current folder. The loop runs until you remove that file:
`rm sitespeed.run`

The loop stops when the current run(s) are finished.

## Start on reboot
To start the tests again when the server reboots, add this to the crontab with `crontab -e` (change the path to where you cloned the repository):

```bash
@reboot rm /root/dashboard.sitespeed.io/sitespeed.run;cd /root/dashboard.sitespeed.io/ && ./loop.sh
```
