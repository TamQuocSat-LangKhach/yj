
local qiangzhi = fk.CreateSkill {
  name = "qiangzhi",
}

Fk:loadTranslationTable{
  ["qiangzhi"] = "强识",
  [":qiangzhi"] = "出牌阶段开始时，你可以展示一名其他角色的一张手牌，当你于此阶段内使用与此牌类别相同的牌时，你可以摸一张牌。",

  ["#qiangzhi-choose"] = "强识：展示一名其他角色的一张手牌，此阶段内你使用类别相同的牌时，你可以摸一张牌",
  ["@qiangzhi-phase"] = "强识",
  ["#qiangzhi-invoke"] = "强识：你可以摸一张牌",

  ["$qiangzhi1"] = "容我过目，即刻咏来。",
  ["$qiangzhi2"] = "文书强识，才可博于运筹。",
}

qiangzhi:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
  return target == player and player:hasSkill(qiangzhi.name) and player.phase == Player.Play and
    table.find(player.room:getOtherPlayers(player, false), function(p)
      return not p:isKongcheng()
    end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(player.room:getOtherPlayers(player, false), function(p)
      return not p:isKongcheng()
    end)
    local to = room:askToChoosePlayers(player, {
      skill_name = qiangzhi.name,
      min_num = 1,
      max_num = 1,
      targets = targets,
      prompt = "#qiangzhi-choose",
      cancelable = true,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(qiangzhi.name, 1)
    room:notifySkillInvoked(player, qiangzhi.name, "control")
    local to = event:getCostData(self).tos[1]
    local card = room:askToChooseCard(player, {
      target = to,
      flag = "h",
      skill_name = qiangzhi.name,
    })
    local type = Fk:getCardById(card):getTypeString()
    to:showCards(card)
    if not player.dead then
      room:setPlayerMark(player, "@qiangzhi-phase", type)
    end
  end,
})

qiangzhi:addEffect(fk.CardUsing, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
  return target == player and player.phase == Player.Play and
    data.card:getTypeString() == player:getMark("@qiangzhi-phase")
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = qiangzhi.name,
      prompt = "#qiangzhi-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
  local room = player.room
    player:broadcastSkillInvoke("qiangzhi", 2)
    room:notifySkillInvoked(player, qiangzhi.name, "drawcard")
    player:drawCards(1, qiangzhi.name)
  end,
})

return qiangzhi
