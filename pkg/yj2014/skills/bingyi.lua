local bingyi = fk.CreateSkill {
  name = "bingyi"
}

Fk:loadTranslationTable{
  ['bingyi'] = '秉壹',
  ['#bingyi-choose'] = '秉壹：你可以令至多%arg名角色各摸一张牌',
  [':bingyi'] = '结束阶段开始时，你可以展示所有手牌，若均为同一颜色，则你令至多X名角色各摸一张牌（X为你的手牌数）。',
  ['$bingyi1'] = '公正无私，秉持如一。',
  ['$bingyi2'] = '诸君看仔细了！',
}

bingyi:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(bingyi) and player.phase == Player.Finish and not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player.player_cards[Player.Hand]
    player:showCards(cards)
    for _, id in ipairs(cards) do
      if Fk:getCardById(id).color ~= Fk:getCardById(cards[1]).color then
        return
      end
    end
    local tos = room:askToChoosePlayers(player, {
      targets = table.map(room:getAlivePlayers(), Util.IdMapper),
      min_num = 1,
      max_num = #cards,
      prompt = "#bingyi-choose:::"..#cards,
      skill_name = bingyi.name,
    })
    if #tos > 0 then
      for _, p in ipairs(tos) do
        room:getPlayerById(p):drawCards(1, bingyi.name)
      end
    end
  end,
})

return bingyi