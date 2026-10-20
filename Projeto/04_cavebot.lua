-- Cavebot: anda a rota so quando NAO esta em combate.
-- Combate (segurar target, kite, spell/runa) = aba Target.

setDefaultTab("Cave")

UI.Label("Cavebot — rota (Paladin Run no Target)")
UI.Label("Enquanto Targeting luta, a rota pausa.")
UI.Label("Sem target: segue o loop gravado.")
UI.Separator()

if type(storage.cave) ~= "table" then
  storage.cave = {
    waypoints = {},
    index = 1,
    recordEvery = 3,
    reach = 1,
  }
end
if type(storage.cave.waypoints) ~= "table" then
  storage.cave.waypoints = {}
end

local caveLabel = UI.Label("Waypoints: 0")

local function refreshLabel()
  local n = #(storage.cave.waypoints or {})
  local idx = storage.cave.index or 1
  local fight = storage._fighting and "FIGHT" or "WALK"
  caveLabel:setText(string.format("WP %d | #%d | %s", n, math.min(idx, math.max(n, 1)), fight))
end
refreshLabel()

UI.Label("Gravar a cada N passos:")
UI.TextEdit(tostring(storage.cave.recordEvery or 3), function(_, text)
  storage.cave.recordEvery = math.max(1, math.min(8, tonumber(text) or 3))
end)

local recording = false
local lastRecordPos = nil

local function dist2(a, b)
  return math.max(math.abs(a.x - b.x), math.abs(a.y - b.y))
end

UI.Button("Gravar / Parar gravacao", function()
  recording = not recording
  lastRecordPos = nil
  if recording then
    info("Gravando rota — ande o loop")
    local p = player:getPosition()
    table.insert(storage.cave.waypoints, { x = p.x, y = p.y, z = p.z })
    refreshLabel()
  else
    info("Gravacao parada (" .. #storage.cave.waypoints .. " pontos)")
  end
end)

onPlayerPositionChange(function(newPos, oldPos)
  if not recording then
    return
  end
  if not lastRecordPos then
    lastRecordPos = oldPos or newPos
  end
  if newPos.z ~= lastRecordPos.z then
    table.insert(storage.cave.waypoints, { x = newPos.x, y = newPos.y, z = newPos.z })
    lastRecordPos = newPos
    refreshLabel()
    return
  end
  local every = storage.cave.recordEvery or 3
  if dist2(newPos, lastRecordPos) >= every then
    table.insert(storage.cave.waypoints, { x = newPos.x, y = newPos.y, z = newPos.z })
    lastRecordPos = newPos
    refreshLabel()
  end
end)

UI.Button("Apagar rota", function()
  storage.cave.waypoints = {}
  storage.cave.index = 1
  recording = false
  refreshLabel()
end)

UI.Button("Marcar SQM atual", function()
  local p = player:getPosition()
  table.insert(storage.cave.waypoints, { x = p.x, y = p.y, z = p.z })
  refreshLabel()
end)

UI.Separator()

local function advanceWaypoint(me)
  local wps = storage.cave.waypoints
  if #wps == 0 then
    return nil
  end
  local idx = storage.cave.index or 1
  if idx < 1 or idx > #wps then
    idx = 1
  end
  local reach = storage.cave.reach or 1
  local wp = wps[idx]
  if wp.z == me.z and dist2(me, wp) <= reach then
    idx = idx + 1
    if idx > #wps then
      idx = 1
    end
    storage.cave.index = idx
    wp = wps[idx]
    refreshLabel()
  end
  return wp
end

local caveMacro = macro(200, "cave walk", function()
  refreshLabel()
  if recording then
    return
  end
  -- combate tem prioridade (Targeting segura o mob ate matar)
  if storage._fighting then
    return
  end
  local fleeAt = (storage.flee and storage.flee.at) or 35
  if player:getHealthPercent() <= fleeAt then
    return
  end

  local wps = storage.cave.waypoints
  if not wps or #wps < 2 then
    return
  end

  local me = player:getPosition()
  local wp = advanceWaypoint(me)
  if not wp then
    return
  end

  autoWalk(wp, 30, {
    ignoreCreatures = true,
    ignoreNonPathable = true,
    precision = 1,
  })
end)

UI.Label("Ligue 'cave walk' + 'targeting' (Target)")
UI.Separator()
UI.Label("Fluxo Magebot-like:")
UI.Label("1) Target: modo paladin_run + spell/runa")
UI.Label("2) Cave: grave loop e ligue cave walk")
