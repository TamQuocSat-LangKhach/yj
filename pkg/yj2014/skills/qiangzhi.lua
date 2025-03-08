```lua
local qiangzhi = fk.CreateSkill {
  name = "qiangzhi"
}

Fk:loadTranslationTable{
  ['qiangzhi'] = '强识',
  ['#qiangzhi-choose'] = '强识：展示一名其他角色的一张手牌，此阶段内你使用类别相同的牌时，你可以摸一张牌',
  ['@qiangzhi-phase'] = '强识',
  ['#qiangzhi-invoke'] = '强识：你可以摸一张牌',
  [':qiangzhi'] = '出牌阶段开始时，你可以展示一名其他角色的一张手牌，然后当你于此阶段内使用与此牌类别相同的牌时，你可以摸一张牌。',
  ['$qiangzhi1'] = '容我过目，即刻咏来。',
  ['$qiangzhi2'] = '文书强识，才可博于运筹。',
}

qiangzhi:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
  return target == player and player:hasSkill(qiangzhi.name) and player.phase == Player.Play and
    table.find(player.room:getOtherPlayers(player), function(p) return p:getHandcardNum() > 0 end)
  end,
  on_cost = function(self, event, target, player, data)
  local room = player.room
  local targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
    return not p:isKongcheng() end), Util.IdMapper)
  local to = room:askToChoosePlayers(player, {
    targets = targets,
    min_num = 1,
    max_num = 1,
    prompt = "#qiangzhi-choose",
    skill_name = qiangzhi.name,
    cancelable = true
  })
  if #to > 0 then
    event:setCostData(self, to[1].id)
    return true
  end
  end,
  on_use = function(self, event, target, player, data)
  local room = player.room
  player:broadcastSkillInvoke(qiangzhi.name, 1)
  room:notifySkillInvoked(player, qiangzhi.name, "control")
  local to = room:getPlayerById(event:getCostData(self))
  room:doIndicate(player.id, {event:getCostData(self)})
  local card = Fk:getCardById(room:askToChooseCard(player, {
    target = to,
    flag = "h",
    skill_name = qiangzhi.name
  }))
  to:showCards(card)
  local cardType = card:getTypeString()
  if cardType ~= "notype" then room:setPlayerMark(player, "@qiangzhi-phase", cardType) end
  end,
})

qiangzhi:addEffect(fk.CardUsing, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
  return target == player and player.phase == Player.Play and player:getMark("@qiangzhi-phase") ~= 0 and
    data.card:getTypeString() == player:getMark("@qiangzhi-phase")
  end,
  on_cost = function(self, event, target, player, data)
  return player.room:askToSkillInvoke(player, {
    skill_name = "qiangzhi",
    prompt = "#qiangzhi-invoke"
  })
  end,
  on_use = function(self, event, target, player, data)
  local room = player.room
  player:broadcastSkillInvoke("qiangzhi", 2)
  room:notifySkillInvoked(player, "qiangzhi", "drawcard")
  player:drawCards(1, qiangzhi.name)
  end,
})

return qiangzhi
```