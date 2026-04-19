# Quickstart: Shmup Phoenix + Mise

## Prerequisites

- [Mise](https://mise.jdx.dev/) installed
- No Postgres required for `--no-ecto` (no `mix ecto.create`)

## 1. Erlang & Elixir (Mise)

From the repository root (after Phoenix app exists, same applies):

```bash
# Example — replace versions with those in .mise.toml after pinning
mise install
mise exec -- erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell
mise exec -- elixir --version
```

Create **`.mise.toml`** (or `.tool-versions`) with the Erlang/Elixir versions chosen for this project. Re-run `mise install` on clone.

## 2. Bootstrap Phoenix (once per repo)

```bash
mix local.hex --force
mix archive.install hex phx_new --force
mix phx.new shmup --no-ecto
```

Use the generated app directory (here **`shmup/`**) or move its contents to repo root—stay consistent with [plan.md](./plan.md) structure.

## 3. Run

```bash
cd shmup   # if applicable
mix deps.get
mix assets.setup
mix phx.server
```

Open `http://localhost:4000` (default).

## 4. Tests

```bash
mix test
```

## 5. Hook development

- Register the Hook in `assets/js/app.js`
- Implement `assets/js/hooks/game_hook.js`
- Rebuild assets: `mix assets.build` or dev watcher as provided by Phoenix

See [contracts/liveview-hook-events.md](./contracts/liveview-hook-events.md) for event names and payloads.
