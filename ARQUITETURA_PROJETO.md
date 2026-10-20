# Bot OTClient: como funciona (e o que isso muda no Olders)

## Ideia-chave (sua pesquisa = correta)

Um bot de OTClient **não abre segunda conexão** com o servidor.

Ele roda **dentro do processo do client** e chama a API do jogo:

| Ação do bot | API típica (OTC / OTCv8) | O que o client faz |
|-------------|--------------------------|--------------------|
| Andar | `g_game.walk` / `autoWalk` | Monta o pacote de movimento |
| Atacar | `g_game.attack(creature)` / `attack()` | Monta o pacote de attack |
| Falar / magia | `g_game.talk` / `say("exura")` | Monta o pacote de speak |
| Usar item | `g_game.use` / `usewith` | Monta o pacote de use |

Você **não inventa pacotes**. O client já sabe o protocolo; o bot só decide *quando* chamar.

```
┌─────────────────────────────────────────┐
│  OTClient (uma sessão, você VÊ a tela)  │
│                                         │
│   Projeto / módulo .lua                 │
│        │                                │
│        ▼                                │
│   g_game / macros / UI                  │
│        │                                │
│        ▼                                │
│   protocol do client  ──►  servidor     │
└─────────────────────────────────────────┘
```

## Duas formas de colocar código (clients ABERTOS)

### 1) Módulo próprio (`.otmod` + `.lua`)

Pasta `mods/meu_modulo/` ou `modules/...`:

- `meu_modulo.otmod` — declara o módulo
- `meu_modulo.lua` — `init()`, macros, UI

Exemplo neste repo: `exemplos/modulo_cura70/`

### 2) Script do bot OTCv8 (`game_bot`)

Pasta `/bot/Projeto/` com `01_*.lua`, `02_*.lua`…  
Carrega pelo botão **Bot** → config → Enable.

É o que já temos: `Projeto/` (cura 3 faixas, target, cave, tools).

Exemplo mínimo: `exemplos/script_projeto_cura_ataque/`

## Clients fechados (Olders, etc.)

Só o essencial — **sem “como furar”**:

- Módulos vêm `.enc` com chave do servidor.
- Lua aberto em `modules/` é **ignorado** (foi o que vimos no Olders).
- Trocar `game_bot` por versão aberta: Trainer some e o Bot novo **não sobe**.
- Motor externo (segunda sessão): age no char, mas **some da tela** que você olha.

Conclusão alinhada à sua pesquisa: **não vale começar o Projeto pelo client fechado**.  
Desenvolve e valida no **Floripa** (aberto). No Olders, peça ao staff liberação de `game_bot` / scripts `/bot` (eles já autorizam OTCv8).

## Conselhos (os que você listou)

1. Antes de chamar: `if g_game.attack then ... end` (ou `pcall`).
2. Ler `modules/game_*` do **próprio** client aberto.
3. Log: `g_logger.info` / `print` / `info()` no bot.
4. Testar em servidor local / Floripa antes do Olders.
5. Não enviar pacotes inventados — só API do client.

## Mapa do nosso projeto

| Onde | O que |
|------|--------|
| `Projeto/` | Config OTCv8 completa (caminho certo) |
| `exemplos/modulo_cura70/` | Módulo mínimo `.otmod` + `.lua` |
| `exemplos/script_projeto_cura_ataque/` | Script mínimo do bot (cura + attack nearest) |
| `sync_projeto.py` / `Projeto_Iniciar.bat` | Copia `Projeto/` para os writeDirs e abre o Floripa |
| `abrir_floripa.bat` | Só abre o client Floripa |
| FloripaOT client | Onde o Projeto deve ser usado e evoluído |
| Olders client | Trainer `.enc` até o staff liberar bot aberto |
