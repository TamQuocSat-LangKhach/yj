local shenduan_viewas = fk.CreateSkill {
  name = "shenduan_viewas",
}

Fk:loadTranslationTable{
  ["shenduan_viewas"] = "慎断",
}

shenduan_viewas:addEffect("viewas", {
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and table.contains(Fk:currentRoom().discard_pile, to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    local c = Fk:cloneCard("supply_shortage")
    c.skillName = "shenduan"
    c:addSubcard(cards[1])
    return c
  end,
})

return shenduan_viewas
