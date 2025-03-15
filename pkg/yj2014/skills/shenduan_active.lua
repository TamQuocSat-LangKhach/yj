local shenduan = fk.CreateSkill {
  name = "shenduan"
}

Fk:loadTranslationTable{
  ['shenduan_active'] = '慎断',
  ['shenduan'] = '慎断',
}

shenduan:addEffect('viewas', {
  expand_pile = function () return Self:getTableMark("shenduan") end,
  card_filter = function(self, player, to_select, selected)
  if #selected == 0 then
    local ids = player:getMark("shenduan")
    return type(ids) == "table" and table.contains(ids, to_select)
  end
  end,
  view_as = function(self, player, cards)
  if #cards ~= 1 then return nil end
  local c = Fk:cloneCard("supply_shortage")
  c.skillName = skill.name
  c:addSubcard(cards[1])
  return c
  end,
})

return shenduan