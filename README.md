# raid.network

An Elixir+React app to help Pokemon Go players find people to play with, with as less clicks as possible.

It is separated between `cyndaquil`, the elixir app containing the queues (contained within `GenServer`s), the matchmakers, and the webserver to interact with them, and `wooloo`, the React PWA that allows clients to interact with the Queue server. 

## Running and testing

This is a `mix` project, so all the regulars apply. Check the [introduction to Mix](https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html) page for more information.

`mix deps.get` to get all dependencies

`mix run --no-halt` to run the application

`iex -S mix` to run the app with a REPL

`mix test --no-start` to run tests (>1 seconds!)

`mix release prod` to create a [Mix release](https://hexdocs.pm/mix/Mix.Tasks.Release.html) to be deployed

## Relevant folders
`/` Root directory contains the Elixir app data (`cyndaquil`)
1. `/lib/` Contains the web server and core code for the Elixir app
1. `/test/` Contains tests related to the Elixir app

`/terraform/` Contains the terraform files that contain the application's infrastructure (further information inside the folder's README)

`/wooloo/` Contains the React PWA that powers the user's interface (further information inside the folder's README)

## Deployment

Run `./build_release.sh` to build the app (it assumes a deploy location and that said location is in your `ssh` keyring) and `scp` the release to the API infrastructure node. Then replace the release as you will (usually by `ssh`ing to the node and restarting the service)
