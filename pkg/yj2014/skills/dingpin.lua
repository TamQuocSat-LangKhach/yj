```lua
local dingpin = fk.CreateSkill {
  name = "dingpin"
}

Fk:loadTranslationTable{
  ['dingpin'] = '定品',
  [':dingpin'] = '出牌阶段，你可以弃置一张与你本回合已使用或弃置的牌类别均不同的手牌，然后令一名已受伤的角色进行一次判定，若结果为黑色，该角色摸X张牌（X为该角色已损失的体力值），然后你本回合不能再对其发动〖定品〗；若结果为红色，将你的武将牌翻面。',
  ['$dingpin1'] = '取才赋职，论能行赏。',
  ['$dingpin2'] = '定品寻良骥，中正探人杰。',
}

dingpin:addEffect('active', {
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
  return not player:isKongcheng()
  end,
  card_filter = function(self, player, to_select, selected)
  if #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip and not player:prohibitDiscard(Fk:getCardById(to_select)) then
    local types = player:getMark("dingpin-turn")
    if type(types) == "table" then
    return not table.contains(types, Fk:getCardById(to_select):getTypeString())
    else
    return true
    end
  end
  end,
  target_filter = function(self, player, to_select, selected)
  local target = Fk:currentRoom():getPlayerById(to_select)
  return #selected == 0 and target:isWounded() and target:getMark("dingpin_target-turn") == 0
  end,
  on_use = function(self, room, effect)
  local player = room:getPlayerById(effect.from)
  local target = room:getPlayerById(effect.tos[1])
  room:throwCard(effect.cards, dingpin.name, player)
  local judge = {
    who = target,
    reason = dingpin.name,
    pattern = ".|.|spade,club",
  }
  room:judge(judge)
  if judge.card.color == Card.Black then
    target:drawCards(target:getLostHp(), dingpin.name)
    room:setPlayerMark(target, "dingpin_target-turn", 1)
  elseif judge.card.color == Card.Red then
    player:turnOver()
  end
   end
})

dingpin:addEffect(fk.CardUsing, {
  can_refresh = function(self, event, target, player, data)
  if player:hasSkill(dingpin) and player.phase ~= Player.NotActive then
    return target == player
  end
  end,
  on_refresh = function(self, event, target, player, data)
  local room = player.room
  local types = player:getMark("dingpin-turn")
  if types == 0 then types = {} end
  table.insertIfNeed(types, data.card:getTypeString())
  room:setPlayerMark(player, "dingpin-turn", types)
  end,
})

dingpin:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
  if player:hasSkill(dingpin) and player.phase ~= Player.NotActive then
    for _, move in ipairs(data) do
    if move.from == player.id and move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
      return true
    end
    end
  end
  end,
  on_refresh = function(self, event, target, player, data)
  local room = player.room
  local types = player:getMark("dingpin-turn")
  if types == 0 then types = {} end
  for _, move in ipairs(data) do
    if move.from == player.id and move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
    for _, info in ipairs(move.moveInfo) do
      table.insertIfNeed(types, Fk:getCardById(info.cardId):getTypeString())
    end
    end
  end
  room:setPlayerMark(player, "dingpin-turn", types)
  end,
})

return dingpin
```