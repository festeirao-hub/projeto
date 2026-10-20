-- Exemplo de SCRIPT do bot OTCv8 (pasta /bot/ExemploCuraAtaque/).
-- Copia esta pasta para: %AppData%\OTClientV8\<seu-client>\bot\ExemploCuraAtaque
-- No jogo: Bot → ExemploCuraAtaque → Enable
--
-- Mesma ideia do Projeto: macro + say/attack — tudo in-client, voce a tela.

setDefaultTab("Main")
UI.Label("Exemplo: cura <70% + ataque ao monstro mais perto")
UI.Separator()

-- Auto cura
macro(200, "heal <70%", function()
  if hppercent() <= 70 then
    say("exura")
  end
end)

-- Auto ataque: monstro mais proximo na tela
macro(300, "attack nearest", function()
  if g_game.getAttackingCreature and g_game.getAttackingCreature() then
    return
  end
  local me = pos()
  local best, bestDist = nil, 99
  for _, spec in ipairs(getSpectators()) do
    if spec:isMonster() and spec:getHealthPercent() > 0 then
      local d = getDistanceBetween(me, spec:getPosition())
      if d < bestDist then
        best, bestDist = spec, d
      end
    end
  end
  if best then
    attack(best)
  end
end)

UI.Label("Projeto completo: Projeto/")
