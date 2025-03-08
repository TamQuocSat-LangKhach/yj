local jiaozhao = fk.CreateSkill {
  name = "jiaozhao"
}

Fk:loadTranslationTable{
  ['jiaozhao'] = '矫诏',
  ['#jiaozhao'] = '矫诏：展示一张手牌令一名角色声明一种基本牌，你本回合可以将此牌当声明的牌使用',
  ['#jiaozhao-choice'] = '矫诏：声明一种牌名，%src 本回合可以将%arg当此牌使用',
  ['jiaozhao_choice'] = '矫诏声明牌名：',
  ['@jiaozhao-inhand'] = '矫诏',
  ['jiaozhaoVS'] = '矫诏',
  [':jiaozhao'] = '出牌阶段限一次，你可以展示一张手牌并选择一名距离最近的其他角色，该角色声明一种基本牌的牌名，本回合你可以将此牌当声明的牌使用（不能指定自己为目标）。',
  ['$jiaozhao1'] = '诏书在此，不得放肆！',
  ['$jiaozhao2'] = '妾身也是逼不得已，方才出此下策。',
}

-- 主动技能部分
jiaozhao:addEffect('active', {
  anim_type = "special",
  card_num = 1,
  target_num = 1,
  prompt = "#jiaozhao",
  can_use = function(skill, player)
    return not player:isKongcheng() and table.every(jiaozhaoSkills, function(s) return player:usedSkillTimes(s, Player.HistoryPhase) == 0 end)
  end,
  card_filter = function(skill, player, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  target_filter = function(skill, player, to_select, selected)
    if #selected == 0 then
      local n = 999
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        if p ~= player and player:distanceTo(p) < n then
          n = player:distanceTo(p)
        end
      end
      return player:distanceTo(Fk:currentRoom():getPlayerById(to_select)) == n
    end
  end,
  on_use = function(skill, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    player:showCards(effect.cards)
    if player.dead then return end
    local c = Fk:getCardById(effect.cards[1])
    local names = {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if card.type == Card.TypeBasic and not card.is_derived then
        table.insertIfNeed(names, card.name)
      end
    end
    local choice = room:askToChoice(target, {
      choices = names,
      skill_name = jiaozhao.name,
      prompt = "#jiaozhao-choice:"..player.id.."::"..c:toLogString()
    })
    room:doBroadcastNotify("ShowToast", Fk:translate("jiaozhao_choice")..Fk:translate(choice))
    if room:getCardOwner(c) == player and room:getCardArea(c) == Card.PlayerHand then
      room:setCardMark(c, "jiaozhao-inhand", choice)
      room:setCardMark(c, "@jiaozhao-inhand", Fk:translate(choice))
      room:handleAddLoseSkills(player, "-jiaozhao|jiaozhaoVS", nil, false, true)
    end
  end,
})

-- 触发技能部分
jiaozhao:addEffect(fk.GameStart, {
  can_refresh = function(skill, event, target, player, data)
    return player:hasSkill(jiaozhao.name)
  end,
  on_refresh = function(skill, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "jiaozhao_status", 1)
  end,
})

jiaozhao:addEffect(fk.EventAcquireSkill, {
  can_refresh = function(skill, event, target, player, data)
    return target == player and data.name == jiaozhao.name
  end,
  on_refresh = function(skill, event, target, player, data)
    local room = player.room
    if player:getMark("jiaozhao_status") == 0 then
      room:setPlayerMark(player, "jiaozhao_status", 1)
    end
    room:handleAddLoseSkills(player, jiaozhaoSkills[player:getMark("jiaozhao_status")].."|-jiaozhaoVS", nil, false, true)
  end,
})

jiaozhao:addEffect(fk.TurnStart, {
  can_refresh = function(skill, event, target, player, data)
    return target == player and player:hasSkill("jiaozhaoVS", true)
  end,
  on_refresh = function(skill, event, target, player, data)
    local room = player.room
    if player:getMark("jiaozhao_status") == 0 then
      room:setPlayerMark(player, "jiaozhao_status", 1)
    end
    for _, id in ipairs(player:getCardIds("h")) do
      room:setCardMark(Fk:getCardById(id), "jiaozhao-inhand", 0)
      room:setCardMark(Fk:getCardById(id), "@jiaozhao-inhand", 0)
    end
    room:handleAddLoseSkills(player, jiaozhaoSkills[player:getMark("jiaozhao_status")].."|-jiaozhaoVS", nil, false, true)
  end,
})

jiaozhao:addEffect(fk.TurnEnd, {
  can_refresh = function(skill, event, target, player, data)
    return target == player and player:hasSkill("jiaozhaoVS", true)
  end,
  on_refresh = function(skill, event, target, player, data)
    local room = player.room
    if player:getMark("jiaozhao_status") == 0 then
      room:setPlayerMark(player, "jiaozhao_status", 1)
    end
    for _, id in ipairs(player:getCardIds("h")) do
      room:setCardMark(Fk:getCardById(id), "jiaozhao-inhand", 0)
      room:setCardMark(Fk:getCardById(id), "@jiaozhao-inhand", 0)
    end
    room:handleAddLoseSkills(player, jiaozhaoSkills[player:getMark("jiaozhao_status")].."|-jiaozhaoVS", nil, false, true)
  end,
})

return jiaozhao