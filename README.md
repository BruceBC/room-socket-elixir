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

# Configure Envinronment

## .env

**Create a .env file as follows:**

```
export TRUSTED_ORIGIN=wss://www.example.com
```

> Note: If you do not create this .env file, the application will use your computer's ip address as the default trusted origin (dev environment only)


# Production

> ssh root@ip-address

**Run Command**
```
docker run -d -p 443:443 brucebc/websocket:0.1.2
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