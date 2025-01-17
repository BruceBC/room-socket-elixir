import Config

config :websocket,
  trusted_origin: System.get_env("TRUSTED_ORIGIN")

config :cowboy,
  scheme: :https,
  https: [
    # See: http://ezgr.net/increasing-security-erlang-ssl-cowboy/
    port: 443,
    dispatch: [
      _: [
        {"/hardware", Websocket.HardwareHandler, []},
        {"/app", Websocket.AppHandler, []}
      ]
    ],
    # Set `otp_app` when using relative path to certs
    otp_app: :websocket,
    cipher_suite: :strong,
    keyfile: "priv/ssl_prod/key.pem",
    certfile: "priv/ssl_prod/cert.pem",
    dhfile: "priv/ssl_prod/dhparam.pem",
    versions: [:"tlsv1.2", :"tlsv1.1", :tlsv1],
    secure_renegotiate: true,
    reuse_sessions: true,
    honor_cipher_order: true
  ]
