ExUnit.start()
Faker.start()
Ecto.Adapters.SQL.Sandbox.mode(LuppiterAuth.Repo, :manual)

{:ok, _} = Application.ensure_all_started(:ex_machina)
