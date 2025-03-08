local nos__renxin = fk.CreateSkill {
  name = "nos__renxin"
}

Fk:loadTranslationTable{
  ['nos__renxin'] = '仁心',
  ['#nos__renxin-invoke'] = '仁心：你可以将所有手牌交给 %dest，令其回复1点体力',
  [':nos__renxin'] = '当一名其他角色处于濒死状态时，你可以将武将牌翻面并将所有手牌（至少一张）交给该角色。若如此做，该角色回复1点体力。',
  ['$nos__renxin1'] = '冲愿以此仁心，消弭杀机，保将军周全。',
  ['$nos__renxin2'] = '阁下罪不至死，冲愿施以援手相救。',
}

nos__renxin:addEffect(fk.AskForPeaches, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(nos__renxin) and target == player and not player:isKongcheng() and
      player.room:getPlayerById(data.who) and data.who ~= player.id
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = nos__renxin.name,
      prompt = "#nos__renxin-invoke::" .. data.who
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local dying = player.room:getPlayerById(data.who)
    player:turnOver()
    room:obtainCard(dying.id, player:getCardIds(Player.Hand), false, fk.ReasonGive, player.id)
    if not dying.dead and dying:isWounded() then
      room:recover({
        who = dying,
        num = 1,
        recoverBy = player,
        skillName = nos__renxin.name
      })
    end
  end,
})

return nos__renxin