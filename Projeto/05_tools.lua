setDefaultTab("Tools")

UI.Label("Utilitarios")

UI.Label("Haste:")
UI.TextEdit(storage.hasteSpell or "utani hur", function(widget, text)
  storage.hasteSpell = text
end)

macro(500, "haste", function()
  if hasHaste() then return end
  say(storage.hasteSpell or "utani hur")
end)

UI.Label("Utamo:")
UI.TextEdit(storage.manaShield or "utamo vita", function(widget, text)
  storage.manaShield = text
end)

local lastManaShield = 0
macro(200, "mana shield", function()
  if hasManaShield() or lastManaShield + 90000 > now then return end
  if say(storage.manaShield or "utamo vita") then
    lastManaShield = now
  end
end)

UI.Separator()

macro(60000, "anti-idle", function()
  turn(math.random(0, 3))
end)

UI.Separator()
UI.Label("Comida (IDs)")
if type(storage.foodItems) ~= "table" or #storage.foodItems == 0 then
  storage.foodItems = { { id = 3577 }, { id = 3578 }, { id = 3582 } }
end

local foodContainer = UI.Container(function(widget, items)
  storage.foodItems = items
end, true)
foodContainer:setHeight(35)
foodContainer:setItems(storage.foodItems)

macro(10000, "eat food", function()
  if not storage.foodItems[1] then return end
  for _, container in pairs(g_game.getContainers()) do
    for __, item in ipairs(container:getItems()) do
      for i, foodItem in ipairs(storage.foodItems) do
        if item:getId() == foodItem.id then
          return g_game.use(item)
        end
      end
    end
  end
end)
