import Config

config :websocket,
  trusted_origin: System.get_env("TRUSTED_ORIGIN")

config :cowboy,
  scheme: :http,
  http: [
    # See: http://ezgr.net/increasing-security-erlang-ssl-cowboy/
    port: 4000,
    dispatch: [
      _: [
        {"/hardware", Websocket.HardwareHandler, []},
        {"/app", Websocket.AppHandler, []}
      ]
    ],
  ]
