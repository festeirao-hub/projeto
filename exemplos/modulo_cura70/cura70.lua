-- Exemplo de MODULO OTClient (mods/cura70/).
-- Usa so a API do client — nao inventa pacote.
-- Funciona em client ABERTO (ex.: Floripa). Em Olders (.enc) este .otmod e ignorado.

local event = nil
local SPELL = "exura"
local HP_MAX = 70

local function tick()
  if not g_game or not g_game.isOnline or not g_game.isOnline() then
    return
  end
  local player = g_game.getLocalPlayer and g_game.getLocalPlayer()
  if not player then
    return
  end
  local hp = player:getHealthPercent()
  if hp > 0 and hp <= HP_MAX then
    -- talk/say: o client monta o pacote de fala/magia
    if g_game.talk then
      g_game.talk(SPELL)
    elseif modules.game_console and modules.game_console.sendMessage then
      modules.game_console.sendMessage(SPELL)
    end
  end
end

function init()
  g_logger.info("[cura70] modulo carregado — cura se HP <= " .. HP_MAX)
  event = cycleEvent(tick, 400)
end

function terminate()
  if event then
    removeEvent(event)
    event = nil
  end
  g_logger.info("[cura70] modulo descarregado")
end
