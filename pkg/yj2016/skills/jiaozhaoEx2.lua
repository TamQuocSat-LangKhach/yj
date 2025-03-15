```lua
local jiaozhaoEx2 = fk.CreateSkill{
  name = "jiaozhaoEx2"
}

Fk:loadTranslationTable{
  ['jiaozhaoEx2'] = '矫诏',
  ['#jiaozhaoEx2'] = '矫诏：展示一张手牌并声明一种基本牌或普通锦囊牌，你本回合可以将此牌当声明的牌使用',
  ['jiaozhao'] = '矫诏',
  ['#jiaozhao-choice'] = '矫诏：声明一种牌名，%src 本回合可以将%arg当此牌使用',
  ['jiaozhao_choice'] = '矫诏声明牌名：',
  ['@jiaozhao-inhand'] = '矫诏',
  [':jiaozhaoEx2'] = '出牌阶段限一次，你可以展示一张手牌，然后声明一种基本牌或普通锦囊牌的牌名，本回合你可以将此牌当声明的牌使用（不能指定自己为目标）。',
}

jiaozhaoEx2:addEffect('active', {
  mute = true,
  card_num = 1,
  target_num = 0,
  prompt = "#jiaozhaoEx2",
  can_use = function(self, player)
  return not player:isKongcheng() and
    table.every(jiaozhaoSkills, function(s) return player:usedSkillTimes(s, Player.HistoryPhase) == 0 end)
  end,
  card_filter = function(self, player, to_select, selected)
  return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
  local player = room:getPlayerById(effect.from)
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
  local choice = room:askToChoice(player, {
    choices = names,
    skill_name = "jiaozhao",
    prompt = "#jiaozhao-choice:"..player.id.."::"..c:toLogString()
  })
  room:doBroadcastNotify("ShowToast", Fk:translate("jiaozhao_choice")..Fk:translate(choice))
  if room:getCardOwner(c) == player and room:getCardArea(c) == Card.PlayerHand then
    room:setCardMark(c, "jiaozhao-inhand", choice)
    room:setCardMark(c, "@jiaozhao-inhand", Fk:translate(choice))
    room:handleAddLoseSkills(player, "-jiaozhaoEx2|jiaozhaoVS", nil, false, true)
  end
  end,
})

return jiaozhaoEx2
```