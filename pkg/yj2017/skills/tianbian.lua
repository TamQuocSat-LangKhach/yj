local tianbian = fk.CreateSkill {
  name = "tianbian"
}

Fk:loadTranslationTable{
  ['tianbian'] = '天辩',
  ['#tianbian-invoke'] = '天辩：是否用牌堆顶牌拼点？',
  [':tianbian'] = '当你拼点时，你可以改为用牌堆顶的一张牌进行拼点；当你的拼点牌亮出后，若此牌花色为<font color=>♥</font>，则点数视为K。',
  ['$tianbian1'] = '当今天子为刘，天亦姓刘！',
  ['$tianbian2'] = '阁下知其然，而未知其所以然。',
}

tianbian:addEffect(fk.StartPindian, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(skill.name) and (player == data.from or table.contains(data.tos, player))
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
    skill_name = skill.name,
    prompt = "#tianbian-invoke"
    })
  end,
  on_use = function(self, event, target, player, data)
    if player == data.from then
    data.fromCard = Fk:getCardById(player.room.draw_pile[1])
    else
    data.results[player.id] = data.results[player.id] or {}
    data.results[player.id].toCard = Fk:getCardById(player.room.draw_pile[1])
    end
  end,
})

tianbian:addEffect(fk.PindianCardsDisplayed, {
  can_trigger = function(self, event, target, player, data)
  if player:hasSkill(skill.name) then
    if player == data.from and data.fromCard.suit == Card.Heart then
    return true
    elseif data.results[player.id] and data.results[player.id].toCard.suit == Card.Heart then
    return true
    end
  end
  end,
  on_use = function(self, event, target, player, data)
  if player == data.from then
    data.fromCard.number = 13
  elseif data.results[player.id] then
    data.results[player.id].toCard.number = 13
  end
  end,
})

return tianbian