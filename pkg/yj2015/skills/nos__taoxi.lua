local nos__taoxi = fk.CreateSkill {
  name = "nos__taoxi"
}

Fk:loadTranslationTable{
  ['nos__taoxi'] = '讨袭',
  ['#nos__taoxi-invoke'] = '讨袭：你可以亮出 %dest 一张手牌，本回合你可以使用或打出此牌',
  ['#nos__taoxi-choose'] = '讨袭：展示%dest一张手牌',
  ['@@nos__taoxi-inhand-turn'] = '讨袭',
  ['#nos__taoxi_delay'] = '讨袭',
  ['#nos__taoxi_filter'] = '讨袭',
  [':nos__taoxi'] = '出牌阶段限一次，当你使用牌仅指定一名其他角色为目标后，你可以亮出其一张手牌直到回合结束，并且你可以于此回合内将此牌如手牌般使用或打出。回合结束时，若该角色未失去此手牌，则你失去1点体力。',
  ['$nos__taoxi1'] = '策马疾如电，溃敌一瞬间。',
  ['$nos__taoxi2'] = '虎豹骑岂能徒有虚名？杀！',
}

nos__taoxi:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(skill, event, target, player, data)
    return target == player and player:hasSkill(nos__taoxi.name) and player.phase == Player.Play and data.to ~= player.id and
      #AimGroup:getAllTargets(data.tos) == 1 and
      not player.room:getPlayerById(data.to):isKongcheng() and
      player:usedSkillTimes(nos__taoxi.name, Player.HistoryPhase) == 0
  end,
  on_cost = function(skill, event, target, player, data)
    if player.room:askToSkillInvoke(player, {skill_name = nos__taoxi.name, prompt = "#nos__taoxi-invoke::" .. data.to}) then
      event:setCostData(skill, {tos = {data.to}})
      return true
    end
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    local card = room:askToChooseCard(player, {
      target = to,
      flag = "h",
      skill_name = nos__taoxi.name,
      prompt = "#nos__taoxi-choose::" .. data.to
    })
    room:setCardMark(Fk:getCardById(card), "@@nos__taoxi-inhand-turn", 1)
    to:showCards(card)
  end,
})

nos__taoxi:addEffect(fk.TurnEnd, {
  anim_type = "negative",
  can_trigger = function(skill, event, target, player, data)
    return target == player and player:usedSkillTimes(nos__taoxi.name, Player.HistoryTurn) > 0 and not player.dead and
      table.find(player.room:getOtherPlayers(player), function (p)
        return table.find(p:getCardIds("h"), function (id)
          return Fk:getCardById(id):getMark("@@nos__taoxi-inhand-turn") > 0
        end) ~= nil
      end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(skill, event, target, player, data)
    player.room:loseHp(player, 1, "nos__taoxi")
  end,
})

nos__taoxi:addEffect('filter', {
  handly_cards = function (skill, player)
    if player:usedSkillTimes(nos__taoxi.name, Player.HistoryTurn) > 0 then
      local ids = {}
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        for _, id in ipairs(p:getCardIds("h")) do
          if Fk:getCardById(id):getMark("@@nos__taoxi-inhand-turn") > 0 then
            table.insertIfNeed(ids, id)
          end
        end
      end
      return ids
    end
  end,
})

return nos__taoxi