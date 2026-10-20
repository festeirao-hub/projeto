# Projeto — bot OTCv8 (in-client)

Bot para **OTClientV8 aberto** (Floripa e outros OTs que permitem `game_bot`). Roda **dentro do client**: usa `g_game` / macros / UI. Não abre segunda conexão e não inventa pacotes.

Desenvolvido por **festeirao**. Validar no Floripa. No Olders oficial o Trainer vem `.enc` — este Projeto não sobe até o staff liberar bot aberto.

## Como usar (Floripa)

1. Ajuste os caminhos do client em `sync_projeto.py` e nos `.bat` se a pasta do Floripa não for a do seu PC.
2. Rode `Projeto_Iniciar.bat` (sincroniza `Projeto/` para AppData/bot e abre `otclient_gl.exe`).
3. No jogo: **Bot** (ícone no topo) → config **Projeto** → **Enable**.

Atalho só do client: `abrir_floripa.bat`.

## O que o Projeto faz (v0.3)

| Aba | Arquivo | Função |
|-----|---------|--------|
| Main | `Projeto/01_main.lua` | Status HP/MP/posição |
| HP | `Projeto/02_heal.lua` | Cura Light/Medium/High, poções, Flee com SQM livre |
| Target | `Projeto/03_targeting.lua` | Lista de monstros, melee/spell/runa, stand/chase/paladin_run |
| Cave | `Projeto/04_cavebot.lua` | Grava e percorre rota só quando não está lutando |
| Tools | `Projeto/05_tools.lua` | Haste, utamo, anti-idle, comida |

Fluxo Magebot-like: targeting (paladin_run + spell/runa) tem prioridade; cavebot pausa em combate.

## Exemplos didáticos

- `exemplos/modulo_cura70/` — módulo `.otmod` (cura se HP ≤ 70). Copia para `mods/cura70/` em client **aberto**.
- `exemplos/script_projeto_cura_ataque/` — script mínimo do bot (heal + attack nearest).

## Arquitetura

Leia `ARQUITETURA_PROJETO.md`: por que o bot é in-client, diferença módulo vs `game_bot`, e por que não começar pelo client fechado.
