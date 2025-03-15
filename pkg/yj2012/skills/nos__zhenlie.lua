local nos__zhenlie = fk.CreateSkill {
  name = "nos__zhenlie"
}

Fk:loadTranslationTable{
  ['nos__zhenlie'] = '贞烈',
  [':nos__zhenlie'] = '当你的判定牌生效前，你可以亮出牌堆顶的一张牌代替之。',
  ['$nos__zhenlie1'] = '我，绝不屈服！',
  ['$nos__zhenlie2'] = '休要小看妇人志气！'
}

nos__zhenlie:addEffect(fk.AskForRetrial, {
  anim_type = "control",
  on_use = function(self, event, target, player, data)
    local room = player.room
    local move1 = {
      ids = room:getNCards(1),
      toArea = Card.Processing,
      moveReason = fk.ReasonJustMove,
      skillName = nos__zhenlie.name,
      proposer = player.id,
    }
    local move2 = {
      ids = {data.card:getEffectiveId()},
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonJustMove,
      skillName = nos__zhenlie.name,
    }
    room:moveCards(move1, move2)
    data.card = Fk:getCardById(move1.ids[1])
    room:sendLog{
      type = "#ChangedJudge",
      from = player.id,
      to = {player.id},
      card = {move1.ids[1]},
      arg = nos__zhenlie.name
    }
  end,
})

return nos__zhenlie