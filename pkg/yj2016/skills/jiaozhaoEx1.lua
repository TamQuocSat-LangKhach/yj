local jiaozhaoEx1 = fk.CreateSkill {
  name = "jiaozhaoEx1"
}

Fk:loadTranslationTable{
  ['jiaozhaoEx1'] = '矫诏',
  ['#jiaozhaoEx1'] = '矫诏：展示一张手牌令一名角色声明一种基本牌或普通锦囊牌，你本回合可以将此牌当声明的牌使用',
  ['jiaozhao'] = '矫诏',
  ['#jiaozhao-choice'] = '矫诏：声明一种牌名，%src 本回合可以将%arg当此牌使用',
  ['jiaozhao_choice'] = '矫诏声明牌名：',
  ['@jiaozhao-inhand'] = '矫诏',
  [':jiaozhaoEx1'] = '出牌阶段限一次，你可以展示一张手牌，然后选择一名距离最近的其他角色，该角色声明一种基本牌或普通锦囊牌的牌名，本回合你可以将此牌当声明的牌使用（不能指定自己为目标）。',
}

jiaozhaoEx1:addEffect('active', {
  mute = true,
  card_num = 1,
  target_num = 1,
  prompt = "#jiaozhaoEx1",
  can_use = function(skill, player)
  return not player:isKongcheng() and
    table.every(jiaozhaoSkills, function(s) return player:usedSkillTimes(s, Player.HistoryPhase) == 0 end)
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
  player:broadcastSkillInvoke("jiaozhao")
  room:notifySkillInvoked(player, "jiaozhao", "special")
  player:showCards(effect.cards)
  if player.dead then return end
  local c = Fk:getCardById(effect.cards[1])
  local names = {}
  for _, id in ipairs(Fk:getAllCardIds()) do
    local card = Fk:getCardById(id)
    if (card.type == Card.TypeBasic or card:isCommonTrick()) and not card.is_derived then
    table.insertIfNeed(names, card.name)
    end
  end
  local choice = room:askToChoice(target, {
    choices = names,
    skill_name = "jiaozhao",
    prompt = "#jiaozhao-choice:"..player.id.."::"..c:toLogString(),
  })
  room:doBroadcastNotify("ShowToast", Fk:translate("jiaozhao_choice")..Fk:translate(choice))
  if room:getCardOwner(c) == player and room:getCardArea(c) == Card.PlayerHand then
    room:setCardMark(c, "jiaozhao-inhand", choice)
    room:setCardMark(c, "@jiaozhao-inhand", Fk:translate(choice))
    room:handleAddLoseSkills(player, "-jiaozhaoEx1|jiaozhaoVS", nil, false, true)
  end
  end,
})

return jiaozhaoEx1