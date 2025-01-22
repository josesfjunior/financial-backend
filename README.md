# PluginhoEnd

---

## Instalação do Projeto

### Instale o ASDF

```
https://asdf-vm.com/guide/getting-started.html
```

- Localize o arquivo .tool-versions
- Para cada linguagem, instale o plugin correspondente

```
asdf plugin add ...
```

- Após adicionar todos os plugins execute o comando abaixo para instalar todas as versões das linguagens

```
asdf install
```

- Verifique se o erlang compilou ou se faltou alguma dependencia dele instalar, caso tenha faltado instale as dependecias necessarioas.

- Certifique de ter o postgres instalado e configurado

```
https://www.postgresql.org/download/
```

- Verifique se seu elixir e erlang estão instalados

```
erl --version
------------------
iex
```

### Se tudo funcionou bem, vamos configurar tudo para rodar o projeto.

- Instale o hex e o rebar

```
mix local.hex
mix local.rebar
```

- Instale as dependencias do projeto

```
mix deps.get
```

- Crie o banco de dados, certifique de ter o usuario e senha configurados de acordo com o arquivo config/dev.exs

```
mix ecto.create
```

- Rode as migrations

```
mix ecto.migrate
```

- Rode o servidor

```
iex -S mix phx.server
```

---

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix

```

```
