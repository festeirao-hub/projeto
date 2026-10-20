-- Targeting (antes do Cave) — lista de monstros, metodo e modo (Paladin Run = keep distance)

setDefaultTab("Target")

UI.Label("Targeting")
UI.Label("Lista vazia = ataca qualquer monstro")
UI.Separator()

if type(storage.target) ~= "table" then
  storage.target = {
    names = "",
    mode = "paladin_run", -- stand | chase | paladin_run
    runRange = 3,
    attackRange = 7,
    finishBelow = 25, -- quando HP do mob <= isso, persegue pra finalizar
    method = "melee", -- melee | spell | rune | spell_rune
    spell = "exori san",
    runeId = 3155,
    spellDelay = 900,
    runeDelay = 1000,
  }
end

storage._fighting = false
storage._targetId = nil

UI.Label("Monstros — mesma linha, separados por virgula:")
UI.Label('Ex: rotworm, carrion worm, troll')

local namesPreview = UI.Label("Lista: (todos)")

local function refreshNamesPreview()
  local raw = storage.target.names or ""
  if raw:gsub("%s", "") == "" then
    namesPreview:setText("Lista: (todos os monstros)")
    return
  end
  local parts = {}
  for part in raw:gmatch("[^,;\r\n]+") do
    local n = part:lower():gsub("^%s+", ""):gsub("%s+$", "")
    if n ~= "" then
      table.insert(parts, n)
    end
  end
  if #parts == 0 then
    namesPreview:setText("Lista: (todos os monstros)")
  else
    namesPreview:setText("Lista (" .. #parts .. "): " .. table.concat(parts, " | "))
  end
end

local namesEdit = UI.TextEdit(storage.target.names or "", function(_, text)
  storage.target.names = text
  refreshNamesPreview()
end)

UI.Button("Editar lista (janela)", function()
  UI.MultilineEditorWindow(storage.target.names or "", { title = "Monstros (virgula ou linha)" }, function(newValue)
    storage.target.names = newValue or ""
    if namesEdit and namesEdit.setText then
      namesEdit:setText(storage.target.names)
    end
    refreshNamesPreview()
  end)
end)

refreshNamesPreview()

UI.Label("Modo: stand | chase | paladin_run")
UI.TextEdit(storage.target.mode or "paladin_run", function(_, text)
  storage.target.mode = text:lower():gsub("%s+", "")
end)

UI.Label("Run Range (Paladin Run — dist. ideal):")
UI.TextEdit(tostring(storage.target.runRange or 3), function(_, text)
  storage.target.runRange = math.max(1, math.min(6, tonumber(text) or 3))
end)

UI.Label("Attack Range (max SQM pra puxar target):")
UI.TextEdit(tostring(storage.target.attackRange or 7), function(_, text)
  storage.target.attackRange = math.max(1, math.min(10, tonumber(text) or 7))
end)

UI.Label("Finalizar se HP do mob% <=")
UI.TextEdit(tostring(storage.target.finishBelow or 25), function(_, text)
  storage.target.finishBelow = math.max(0, math.min(100, tonumber(text) or 25))
end)

UI.Separator()
UI.Label("Metodo: melee | spell | rune | spell_rune")
UI.TextEdit(storage.target.method or "melee", function(_, text)
  storage.target.method = text:lower():gsub("%s+", "")
end)

UI.Label("Spell de ataque:")
UI.TextEdit(storage.target.spell or "exori san", function(_, text)
  storage.target.spell = text
end)

UI.Label("Rune ID (0 = off):")
UI.TextEdit(tostring(storage.target.runeId or 0), function(_, text)
  storage.target.runeId = tonumber(text) or 0
end)

UI.Label("Delay spell ms:")
UI.TextEdit(tostring(storage.target.spellDelay or 900), function(_, text)
  storage.target.spellDelay = tonumber(text) or 900
end)

UI.Label("Delay rune ms:")
UI.TextEdit(tostring(storage.target.runeDelay or 1000), function(_, text)
  storage.target.runeDelay = tonumber(text) or 1000
end)

UI.Separator()

local function distCheb(a, b)
  return math.max(math.abs(a.x - b.x), math.abs(a.y - b.y))
end

local function parseNameList()
  local raw = storage.target.names or ""
  local list = {}
  -- virgula, ponto-e-virgula ou quebra de linha
  for part in raw:gmatch("[^,;\r\n]+") do
    local n = part:lower():gsub("^%s+", ""):gsub("%s+$", "")
    if n ~= "" then
      table.insert(list, n)
    end
  end
  return list
end

local function nameAllowed(name)
  local list = parseNameList()
  if #list == 0 then
    return true
  end
  name = name:lower()
  for _, n in ipairs(list) do
    if name == n or name:find(n, 1, true) then
      return true
    end
  end
  return false
end

local function tileFree(pos)
  local tile = g_map.getTile(pos)
  if not tile or not tile:isWalkable(false) then
    return false
  end
  local creatures = tile:getCreatures()
  if creatures then
    for _, c in ipairs(creatures) do
      if c and not c:isLocalPlayer() then
        return false
      end
    end
  end
  return true
end

local function pathLen(from, to)
  local path = findPath(from, to, 12, {
    ignoreCreatures = true,
    ignoreNonPathable = true,
    ignoreCost = true,
  })
  if not path then
    return nil
  end
  return #path
end

-- Mantem distancia (Magebot Paladin Run / TargetBot keepDistance)
local function keepRunRange(creature)
  local me = player:getPosition()
  local cpos = creature:getPosition()
  if not cpos or cpos.z ~= me.z then
    return
  end
  local want = storage.target.runRange or 3
  local steps = pathLen(me, cpos)
  if not steps then
    -- tenta achar SQM livre a 'want' do monstro
    local best = nil
    local bestScore = 999
    for dx = -6, 6 do
      for dy = -6, 6 do
        local cand = { x = cpos.x + dx, y = cpos.y + dy, z = cpos.z }
        local d = math.max(math.abs(dx), math.abs(dy))
        if d >= want and d <= want + 1 and tileFree(cand) then
          local p = findPath(me, cand, 14, { ignoreCreatures = true, ignoreNonPathable = true })
          if p and #p < bestScore then
            bestScore = #p
            best = cand
          end
        end
      end
    end
    if best then
      autoWalk(best, 14, { ignoreCreatures = true, ignoreNonPathable = true })
    end
    return
  end
  if steps ~= want and steps ~= want + 1 then
    autoWalk(cpos, 12, {
      ignoreNonPathable = true,
      ignoreCreatures = true,
      marginMin = want,
      marginMax = want + 1,
    })
  end
end

local function chaseTo(creature)
  local cpos = creature:getPosition()
  if not cpos then
    return
  end
  autoWalk(cpos, 12, { ignoreNonPathable = true, ignoreCreatures = true, precision = 1 })
end

-- Paladino: SEMPRE o monstro mais proximo na tela (troca target se outro chegar mais perto)
local function pickTarget()
  local me = player:getPosition()
  local range = storage.target.attackRange or 7
  local best = nil
  local bestD = 99

  for _, spec in ipairs(getSpectators()) do
    if spec:isMonster() and not spec:isLocalPlayer() and spec:getHealthPercent() > 0 then
      if nameAllowed(spec:getName()) then
        local p = spec:getPosition()
        if p and p.z == me.z then
          local d = distCheb(me, p)
          if d <= range and d < bestD then
            bestD = d
            best = spec
          elseif d <= range and d == bestD and best then
            -- empate: prioriza menos HP
            if spec:getHealthPercent() < best:getHealthPercent() then
              best = spec
            end
          end
        end
      end
    end
  end
  return best
end

local lastSpell = 0
local lastRune = 0

local function doAttackMethods(creature)
  local method = storage.target.method or "melee"
  local nowMs = now

  if method == "spell" or method == "spell_rune" then
    local spell = storage.target.spell or ""
    local delay = storage.target.spellDelay or 900
    if #spell > 0 and nowMs - lastSpell >= delay then
      say(spell)
      lastSpell = nowMs
    end
  end

  if method == "rune" or method == "spell_rune" then
    local runeId = storage.target.runeId or 0
    local delay = storage.target.runeDelay or 1000
    if runeId > 100 and nowMs - lastRune >= delay then
      useWith(runeId, creature)
      lastRune = nowMs
    end
  end
end

local targetMacro = macro(100, "targeting", function()
  local fleeAt = (storage.flee and storage.flee.at) or 35
  if player:getHealthPercent() <= fleeAt then
    storage._fighting = false
    storage._targetId = nil
    return
  end

  local creature = pickTarget()
  if not creature then
    storage._fighting = false
    storage._targetId = nil
    if g_game.isAttacking() then
      -- nao cancela se for player; so limpa se target sumiu
    end
    return
  end

  storage._fighting = true
  storage._targetId = creature:getId()

  local current = g_game.getAttackingCreature()
  if current ~= creature then
    g_game.attack(creature)
  end

  doAttackMethods(creature)

  local mode = storage.target.mode or "paladin_run"
  local hp = creature:getHealthPercent()
  local finishBelow = storage.target.finishBelow or 25

  if mode == "stand" then
    return
  end

  -- finalizar: persegue quando mob esta fraco
  if hp <= finishBelow or mode == "chase" then
    chaseTo(creature)
    return
  end

  if mode == "paladin_run" then
    keepRunRange(creature)
  end
end)

targetMacro.setOn()

UI.Label("Sempre troca pro monstro MAIS PROXIMO")
UI.Label("paladin_run = kita na Run Range")
