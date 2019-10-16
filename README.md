# Websocket

**A websocket server that allows hardware and app clients to connect to through a shared hardware id to get realtime monitoring feedback.**

## Installation

1. `Clone project` and `cd` into the websocket directory.

2. `mix deps.get` in terminal to download depedencies.

## Run

`iex -S mix` in terminal to start server.

# Secure WebSockets

## Setup

**In Project Root**

```bash
mkdir priv/ssl
cd priv/ssl
```

**Run Command**

```bash
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=US/ST=State/L=City/O=Business Name/CN=www.example.com" -keyout key.pem -out cert.pem

openssl dhparam -out dhparam.pem 4096

-or-

openssl dhparam -out dhparam.pem 2048
```
**Resoureces:**

[Generate SSL Certificate](https://github.com/ninenines/cowboy/issues/1213)

[Generate Diffie Hellman File](https://hexdocs.pm/plug/1.7.0/Plug.SSL.html#content)

## Keychain

1. Add cert.pem to Keychain
2. Double click certification in keychain and under **trust** select **Always Trust** (This enables the secure websocket to be used in your browser).

**Source**:
[Trust Self Signed SSL Certificate on OS X](https://tosbourn.com/getting-os-x-to-trust-self-signed-ssl-certificates/)

## Verify SSL Certificate

**Run Command**

```bash
openssl s_client -connect www.example.com
```

## Helpful Resources

- [OpenSSL](https://gist.github.com/Soarez/9688998)

- [Config](https://github.com/holsee/wizz/blob/master/config/config.exs)

- [Test Secure WebSocket](https://www.websocket.org/echo.html)

- [Use Origin Header to Secure Websockets from Middleman Attacks](http://www.christian-schneider.net/CrossSiteWebSocketHijacking.html)

# Docker

## Useful Docker Commands

**Build and Run (Interactive):**

```
docker build -t websocket . && docker run -it websocket /bin/bash
```

**Build:**

```
docker build -t websocket .
```

**Run (Interactive):**

```
docker run -it websocket /bin/bash
```

**Build and Run (Foreground/Port):**

```
docker build -t websocket . && docker run -a stdin -a stdout -i -t -p 443:443 websocket
```


# Production

> ssh root@ip-address

**Run Command**
```
docker run -d -p 443:443 brucebc/websocket:0.1.2
```

# Proxy

## Install Ngrok on Linux Server

[Install Ngrok on Linux Server](https://github.com/inconshreveable/ngrok/issues/447#issuecomment-413466612)

```bash
mkdir ngrok

cd ngrok/

sudo apt-get update

sudo apt-get install unzip wget

wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip

unzip ngrok-stable-linux-amd64.zip

rm -rf ngrok-stable-linux-amd64.zip

./ngrok authtoken <auth-token>
```

## Run Ngrok

[Run Ngrok in Background](https://stackoverflow.com/a/48841928)

[View Ngrok Urls Running in Background](https://stackoverflow.com/a/34436976)

```bash
# foreground
./ngrok http <server-ip-address:port>

# background
./ngrok http 167.71.171.185:443 > /dev/null &

# access ngrok url, look for public_url, and copy url without http://, i.e. <subdomain>.ngrok.io
curl localhost:4040/api/tunnels | jq '.'
```

## Stop Ngrok

[List Processes in Linux](https://www.howtogeek.com/107217/how-to-manage-processes-from-the-linux-terminal-10-commands-you-need-to-know/)

```bash
# get a list of running processes, ctrl-c to exit
top

# get a list of running processes
ps -A

# search for ngrok directly
ps -A | grep ngrok

# kill process
kill -9 <pid>
```

## Connect to WebSocket

**Domain:** wss://room.queuedrop.io

> connect to hardware
```JavaScript
const websocket = new WebSocket("wss://room.queuedrop.io/hardware")
```

> connect to app
```JavaScript
const websocket = new WebSocket("wss://room.queuedrop.io/app")
```

# Troubleshooting

- Ensure self-signed certificate is not expired
- Make sure you are testing websockets from Safari as Chrome will not recognize self-signed certificates
- Ensure proxy is up and running and proxy url matches `SERVER_ADDRESS` in Arduino software

# Todo

## Proxy
- Replace Ngrok with custom solution
  - [Search](https://www.google.com/search?client=safari&rls=en&q=run+ngrok+on+digital+ocean%3F&ie=UTF-8&oe=UTF-8)
  - [Self-Hosted Ngrok Alternative](https://www.digitalocean.com/community/questions/self-hosted-ngrok-or-serveo-alternative)
  - [Roll Your Own Ngrok in 15 Minutes](https://zach.codes/roll-your-own-ngrok/)
  - [Ngrok? You Might Not Need It](https://medium.com/@gabriel.bentara/ngrok-you-might-not-need-it-de4e3e34a55d)