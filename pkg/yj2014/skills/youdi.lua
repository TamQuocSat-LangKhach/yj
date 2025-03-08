local youdi = fk.CreateSkill {
  name = "youdi"
}

Fk:loadTranslationTable{
  ['youdi'] = '诱敌',
  ['#youdi-choose'] = '诱敌：令一名其他角色弃置你的一张牌，若不为【杀】，你获得其一张牌',
  [':youdi'] = '结束阶段开始时，你可以令一名其他角色弃置你的一张牌，若此牌不为【杀】，你获得该角色的一张牌。',
  ['$youdi1'] = '无名小卒，可敢再前进一步！',
  ['$youdi2'] = '予以小利，必有大获。',
}

youdi:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  mute = true,
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(youdi.name) and player.phase == Player.Finish and not player:isNude()
  end,
  on_cost = function(self, event, target, player)
    local to = player.room:askToChoosePlayers(player, {
      targets = table.map(player.room:getOtherPlayers(player, false), Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#youdi-choose",
      skill_name = youdi.name,
      cancelable = true
    })
    if #to > 0 then
      event:setCostData(self, to[1])
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local to = room:getPlayerById(event:getCostData(self))
    player:broadcastSkillInvoke(youdi.name, 1)
    room:notifySkillInvoked(player, youdi.name)
    local card = room:askToChooseCard(player, {
      target = to,
      flag = "he",
      skill_name = youdi.name
    })
    room:throwCard({card}, youdi.name, player, to)
    if Fk:getCardById(card).trueName ~= "slash" and not to:isNude() then
      player:broadcastSkillInvoke(youdi.name, 2)
      room:notifySkillInvoked(player, youdi.name)
      local card2 = room:askToChooseCard(player, {
        target = to,
        flag = "he",
        skill_name = youdi.name
      })
      room:obtainCard(player.id, card2, false)
    end
  end,
})

return youdi