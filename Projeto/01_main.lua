-- Projeto — config DENTRO do client OTCv8 (voce ve a tela).

setDefaultTab("Main")

UI.Label("Projeto v0.3")
UI.Label("Client: FloripaOT (bot aberto)")
UI.Separator()
UI.Label("HP: 3 curas + Flee (SQM livre)")
UI.Label("Target: lista / spell-runa / paladin_run")
UI.Label("Cave: rota so quando nao esta lutando")
UI.Separator()

local status = UI.Label("HP --%  MP --%")

macro(500, function()
  local hp = player:getHealthPercent()
  local mp = 0
  local maxMana = player:getMaxMana()
  if maxMana > 0 then
    mp = math.floor(100 * player:getMana() / maxMana)
  end
  status:setText(string.format("HP %d%%  MP %d%%  pos %d,%d,%d", hp, mp, posx(), posy(), posz()))
end)

UI.Separator()
