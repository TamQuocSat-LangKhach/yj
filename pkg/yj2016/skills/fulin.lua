```lua
local fulin = fk.CreateSkill {
  name = "fulin"
}

Fk:loadTranslationTable{
  ['fulin'] = '腹鳞',
  ['@@fulin-inhand'] = '腹鳞',
  [':fulin'] = '锁定技，你于回合内获得的牌不计入手牌上限。',
  ['$fulin1'] = '丞相，丞相！你们没看见我吗？',
  ['$fulin2'] = '我乃托孤重臣，却在这儿搞什么粮草！'
}

fulin:addEffect('maxcards', {
  name = "fulin",
  frequency = Skill.Compulsory,
  exclude_from = function(self, player, card)
    return player:hasSkill(fulin) and card:getMark("@@fulin-inhand") > 0
  end,
})

fulin:addEffect(fk.AfterCardsMove, {
  can_refresh = function(self, event, target, player, data)
    if player:hasShownSkill(fulin, true) then
      if event == fk.AfterCardsMove and player.phase ~= Player.NotActive then
        for _, move in ipairs(data) do
          if move.to == player.id and move.toArea == Card.PlayerHand then
            return true
          end
        end
      elseif event == fk.TurnEnd then
        return target == player
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.AfterCardsMove then
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Card.PlayerHand then
          for _, info in ipairs(move.moveInfo) do
            room:setCardMark(Fk:getCardById(info.cardId), "@@fulin-inhand", 1)
          end
        end
      end
    else
      for _, id in ipairs(player:getCardIds("h")) do
        room:setCardMark(Fk:getCardById(id), "@@fulin-inhand", 0)
      end
    end
  end,
})

fulin:addEffect(fk.EventPhaseStart, {
  can_refresh = function(self, event, target, player, data)
    return player == target and player:hasSkill(fulin) and player.phase == Player.Discard and not player:isFakeSkill(fulin)
      and player:getMaxCards() < player:getHandcardNum() and table.find(player:getCardIds("h"), function (id)
        return Fk:getCardById(id):getMark("@@fulin-inhand") > 0
      end)
  end,
  on_refresh = function(self, event, target, player, data)
    player:broadcastSkillInvoke(fulin.name)
  end,
})

return fulin
```