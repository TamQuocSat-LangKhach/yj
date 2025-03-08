```lua
local xiansi = fk.CreateSkill {
  name = "xiansi"
}

Fk:loadTranslationTable{
  ['xiansi&'] = '陷嗣',
  ['xiansi'] = '陷嗣',
  ['liufeng_ni'] = '逆',
  [':xiansi&'] = '当你需使用【杀】时，你可以弃置刘封的两张“逆”，视为对其使用一张【杀】。',
}

xiansi:addEffect('viewas', {
  anim_type = "negative",
  pattern = "slash",
  card_filter = Util.FalseFunc,
  view_as = function(skill, player, cards)
    local c = Fk:cloneCard("slash")
    c.skillName = skill.name
    return c
  end,
  before_use = function(skill, player, use)
    local room = player.room
    for _, id in ipairs(TargetGroup:getRealTargets(use.tos)) do
      local p = room:getPlayerById(id)
      if p:hasSkill(skill.name, true) and #p:getPile("liufeng_ni") > 1 then
        local cards = table.random(p:getPile("liufeng_ni"), 2)
        room:moveCards({
          from = id,
          ids = cards,
          toArea = Card.DiscardPile,
          moveReason = fk.ReasonPutIntoDiscardPile,
          skillName = skill.name,
        })
        break
      end
    end
  end,
  enabled_at_play = function(skill, player)
    return table.find(Fk:currentRoom().alive_players, function(p)
      return (p:hasSkill(skill.name, true) and #p:getPile("liufeng_ni") > 1)
    end)
  end,
  enabled_at_response = function(skill, player, response)
    return not response and table.find(Fk:currentRoom().alive_players, function(p)
      return (p:hasSkill(skill.name, true) and #p:getPile("liufeng_ni") > 1)
    end)
  end,
})

xiansi:addEffect('prohibit', {
  is_prohibited = function(skill, player, from, to, card)
    if from:hasSkill(skill.name, true) then
      return card.trueName == "slash" and table.contains(card.skillNames, skill.name) and
        not (to:hasSkill(skill.name, true) and #to:getPile("liufeng_ni") > 1)
    end
  end,
})

return xiansi
```