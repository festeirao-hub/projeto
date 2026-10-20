-- Cura em 3 niveis (light / medium / high) + Flee com busca de SQM livre

setDefaultTab("HP")

-- migracao 2->3 slots
if type(storage.healLight) ~= "table" then
  local old1 = storage.healing1
  storage.healLight = {
    on = true,
    title = "Light",
    text = (old1 and old1.text) or "exura",
    min = 70,
    max = 95,
  }
end
if type(storage.healMedium) ~= "table" then
  storage.healMedium = {
    on = true,
    title = "Medium",
    text = "exura gran",
    min = 40,
    max = 70,
  }
end
if type(storage.healHigh) ~= "table" then
  local old2 = storage.healing2
  storage.healHigh = {
    on = true,
    title = "High",
    text = (old2 and old2.text) or "exura vita",
    min = 0,
    max = 40,
  }
end

UI.Label("Healing — Light / Medium / High (estilo Magebot)")
UI.Label("Faixas por HP%. Ligue cada switch.")

local function bindHeal(info)
  local m = macro(50, function()
    local hp = player:getHealthPercent()
    if info.max >= hp and hp >= info.min and info.text and #info.text > 0 then
      say(info.text)
    end
  end)
  m.setOn(info.on)
  UI.DualScrollPanel(info, function(_, newParams)
    info = newParams
    m.setOn(info.on)
  end)
end

UI.Label("LIGHT")
bindHeal(storage.healLight)
UI.Label("MEDIUM")
bindHeal(storage.healMedium)
UI.Label("HIGH")
bindHeal(storage.healHigh)

UI.Separator()
UI.Label("Pocoes / runas")

if type(storage.hpitem1) ~= "table" then
  storage.hpitem1 = { on = false, title = "HP%", item = 266, min = 0, max = 60 }
end
if type(storage.manaitem1) ~= "table" then
  storage.manaitem1 = { on = false, title = "MP%", item = 268, min = 0, max = 40 }
end

for i, healingInfo in ipairs({ storage.hpitem1, storage.manaitem1 }) do
  local healingmacro = macro(100, function()
    local value
    if i == 1 then
      value = player:getHealthPercent()
    else
      local maxMana = player:getMaxMana()
      if maxMana <= 0 then return end
      value = math.floor(100 * player:getMana() / maxMana)
    end
    if healingInfo.max >= value and value >= healingInfo.min and healingInfo.item > 100 then
      local subType = g_game.getClientVersion() >= 860 and 0 or 1
      g_game.useInventoryItemWith(healingInfo.item, player, subType)
    end
  end)
  healingmacro.setOn(healingInfo.on and healingInfo.item > 100)
  UI.DualScrollItemPanel(healingInfo, function(_, newParams)
    healingInfo = newParams
    healingmacro.setOn(healingInfo.on and healingInfo.item > 100)
  end)
end

UI.Separator()
UI.Label("Flee — busca SQM livre longe dos monstros")

if type(storage.flee) ~= "table" then
  storage.flee = { on = true, at = 35, spell = "utani hur", range = 7 }
end
if not storage.flee.range then
  storage.flee.range = 7
end

UI.Label("Flee quando HP% <=")
UI.TextEdit(tostring(storage.flee.at or 35), function(_, text)
  storage.flee.at = tonumber(text) or 35
end)

UI.Label("Spell de fuga:")
UI.TextEdit(storage.flee.spell or "utani hur", function(_, text)
  storage.flee.spell = text
end)

UI.Label("Raio de busca (SQM):")
UI.TextEdit(tostring(storage.flee.range or 7), function(_, text)
  storage.flee.range = math.max(2, math.min(10, tonumber(text) or 7))
end)

local function monsterPositions()
  local list = {}
  for _, spec in ipairs(getSpectators()) do
    if spec:isMonster() and not spec:isLocalPlayer() and spec:getHealthPercent() > 0 then
      local p = spec:getPosition()
      if p then
        table.insert(list, p)
      end
    end
  end
  return list
end

local function minDistToMonsters(x, y, z, monsters)
  local best = 99
  for _, m in ipairs(monsters) do
    if m.z == z then
      local d = math.max(math.abs(m.x - x), math.abs(m.y - y))
      if d < best then
        best = d
      end
    end
  end
  return best
end

local function tileFree(pos, allowCreatures)
  local tile = g_map.getTile(pos)
  if not tile or not tile:isWalkable(false) then
    return false
  end
  if allowCreatures then
    return true
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

-- escolhe o melhor SQM LIVRE (sem criatura) longe dos monstros
local function findFleeTile(me, monsters, range)
  local best = nil
  local bestScore = -9999
  local walkParams = {
    ignoreCreatures = true,
    ignoreNonPathable = true,
  }

  local function consider(requireClearance)
    for dx = -range, range do
      for dy = -range, range do
        if not (dx == 0 and dy == 0) then
          local cand = { x = me.x + dx, y = me.y + dy, z = me.z }
          if tileFree(cand, false) then
            local clearance = minDistToMonsters(cand.x, cand.y, cand.z, monsters)
            local away = math.max(math.abs(dx), math.abs(dy))
            local score = clearance * 20 + away * 2
            if (not requireClearance or clearance >= 2) and score > bestScore then
              local path = findPath(me, cand, range + 4, walkParams)
              if path then
                bestScore = score
                best = cand
              end
            end
          end
        end
      end
    end
  end

  consider(true)
  if not best then
    consider(false)
  end
  -- ultimo recurso: tile walkable mesmo com criatura no caminho do pathfinder
  if not best then
    for dx = -range, range do
      for dy = -range, range do
        if not (dx == 0 and dy == 0) then
          local cand = { x = me.x + dx, y = me.y + dy, z = me.z }
          if tileFree(cand, true) then
            local clearance = minDistToMonsters(cand.x, cand.y, cand.z, monsters)
            local score = clearance * 10 + math.max(math.abs(dx), math.abs(dy))
            if score > bestScore then
              local path = findPath(me, cand, range + 4, walkParams)
              if path then
                bestScore = score
                best = cand
              end
            end
          end
        end
      end
    end
  end

  return best
end

-- passo unico nas 8 dirs se autoWalk falhar
local function stepAway(me, monsters)
  local dirs = {
    { North, 0, -1 }, { NorthEast, 1, -1 }, { East, 1, 0 }, { SouthEast, 1, 1 },
    { South, 0, 1 }, { SouthWest, -1, 1 }, { West, -1, 0 }, { NorthWest, -1, -1 },
  }
  local bestDir = nil
  local bestScore = -1
  for _, d in ipairs(dirs) do
    local cand = { x = me.x + d[2], y = me.y + d[3], z = me.z }
    if tileFree(cand, false) or tileFree(cand, true) then
      local score = minDistToMonsters(cand.x, cand.y, cand.z, monsters)
      if tileFree(cand, false) then
        score = score + 5
      end
      if score > bestScore then
        bestScore = score
        bestDir = d[1]
      end
    end
  end
  if bestDir == nil then
    return false
  end
  walk(bestDir)
  return true
end

local fleeMacro = macro(100, "flee", function()
  local limit = storage.flee.at or 35
  if player:getHealthPercent() > limit then
    return
  end

  g_game.cancelAttackAndFollow()

  if storage.flee.spell and #storage.flee.spell > 0 and not hasHaste() then
    say(storage.flee.spell)
  end

  local me = player:getPosition()
  local monsters = monsterPositions()
  local range = storage.flee.range or 7
  local dest = findFleeTile(me, monsters, range)

  if dest then
    if not autoWalk(dest, range + 3, {
      ignoreCreatures = true,
      ignoreNonPathable = true,
    }) then
      stepAway(me, monsters)
    end
  else
    stepAway(me, monsters)
  end
end)

if storage.flee.on ~= false then
  fleeMacro.setOn()
end
