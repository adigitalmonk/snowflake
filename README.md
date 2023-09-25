# Snowflake

A reliable Snowflake generating system.

## Running

### Environment

You should configure parts of the application.

- `SNOWFLAKE_NODE_ID`
  - Unique identifier for the node.
  - If not specified, will default to 1.
  - Should be a positive integer between 0 and 1023 (inclusive)

- `SNOWFLAKE_PORT_ID`
  - The port that the application will run on.
  - Defaults to 3000

- `SNOWFLAKE_POOL_SIZE`
  - The number of TCP listeners to have.
  - You likely don't need more than 1, but if you have a lot of connections opening concurrently you'll possibly need to raise this.
  - Defaults to 1

- `SNOWFLAKE_LOG_LEVEL`
  - Log level for the application
  - Defaults to `warning`
  - See `config/runtime.exs` for the mapping.

### Via Docker / Compose

The `docker-compose.yml` will load configuration from a `.env` file.
The port should be set in your environment as well because it's specified in as compose file variable.

```
> docker compose up -d
[+] Running 1/1
 ✔ Container snowflake-app-1  Started
```

If you want to use the Docker image directly, you can refer to the compose file as a reference.

### Via Release

You'll want the environment variables set in the current session.
I generally recommend [direnv](https://direnv.net/) for this.

There's an `.envrc.example` that can be used to create the `.envrc` for `direnv`.

```
> sh build_release.sh
==> echo
Compiling 9 files (.ex)
Generated echo app
==> snowflake
Compiling 5 files (.ex)
Generated snowflake app
* assembling snowflake-0.1.0 on MIX_ENV=prod
* using config/runtime.exs to configure the release at runtime
* skipping elixir.bat for windows (bin/elixir.bat not found in the Elixir installation)
* skipping iex.bat for windows (bin/iex.bat not found in the Elixir installation)

Release created at _build/prod/rel/snowflake

    # To start your system
    _build/prod/rel/snowflake/bin/snowflake start

Once the release is running:

    # To connect to it remotely
    _build/prod/rel/snowflake/bin/snowflake remote

    # To stop it gracefully (you may also send SIGINT/SIGTERM)
    _build/prod/rel/snowflake/bin/snowflake stop

To list all commands:

    _build/prod/rel/snowflake/bin/snowflake
```

Then you can start the application via the generated `snowflake` script.

```
> ./_build/prod/snowflake/bin/snowflake start
```

You can stop it similarly.

```
> ./_build/prod/snowflake/bin/snowflake stop
```

## Usage

Once the server is online, you can connect to it on the configured port, then send it the "GET" command.
The server will respond with a uniquely generated Snowflake ID.

```
➜  ~ telnet localhost 4000
Trying ::1...
Connected to localhost.
Escape character is '^]'.
GET
7112154985684545536
GET
7112154990516383745
GET
7112154993175572482
GET
7112154995604074499
```

Any unsupported commands (currently, anything besides 'GET') will not respond.

```
GET
7112154995604074499
NOTGET
SOMETHINGELSE
GET
7112155162642231300
```

### Demo

An example of a _really_ basic server connection would be something like:

```elixir
defmodule Demo.Snowflake.Client do
  use GenServer

  def connect(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def get(name \\ __MODULE__) do
    GenServer.call(name, :get)
  end

  @impl GenServer
  def init(_opts) do
    :gen_tcp.connect(~c"localhost", 4000, [:binary, active: false])
  end

  @impl GenServer
  def handle_call(:get, _from, port) do
    :ok = :gen_tcp.send(port, "get\n")
    {:ok, msg} = :gen_tcp.recv(port, 0, 5000)

    snowflake =
      msg
      |> String.trim()
      |> String.to_integer()

    {:reply, snowflake, port}
  end
end
```

And then used like...

```elixir
iex(1)> alias Demo.Snowflake.Client
Demo.Snowflake.Client
iex(2)> Client.connect()
{:ok, #PID<0.119.0>}
iex(3)> Client.get()
7112175726840795144
iex(4)> Client.get()
7112175730640834569
iex(5)> Client.get()
7112175733463601162
```
