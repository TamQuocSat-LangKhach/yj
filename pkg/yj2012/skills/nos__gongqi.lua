
local nos__gongqi = fk.CreateSkill {
  name = "nos__gongqi"
}

Fk:loadTranslationTable{
  ['nos__gongqi'] = '弓骑',
  [':nos__gongqi'] = '你可以将一张装备牌当【杀】使用或打出；你以此法使用的【杀】无距离限制。',
  ['$nos__gongqi1'] = '鼠辈，哪里走！',
  ['$nos__gongqi2'] = '吃我一箭！',
}

nos__gongqi:addEffect('viewas', {
  anim_type = "offensive",
  pattern = "slash",
  card_filter = function(self, player, to_select, selected)
    if #selected == 1 then return false end
    return Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    local card = Fk:cloneCard("slash")
    card:addSubcard(cards[1])
    card.skillName = nos__gongqi.name
    return card
  end,
})

nos__gongqi:addEffect('targetmod', {
  distance_limit_func = function(self, player, skill, card)
    if table.contains(card.skillNames, "nos__gongqi") then
      return 999
    end
  end,
})

return nos__gongqi
