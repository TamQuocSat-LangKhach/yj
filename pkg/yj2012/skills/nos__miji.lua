local nos__miji = fk.CreateSkill {
  name = "nos__miji"
}

Fk:loadTranslationTable{
  ['nos__miji'] = '秘计',
  ['#nos__miji-choose'] = '秘计：选择一名角色获得“秘计”牌',
  [':nos__miji'] = '准备阶段或结束阶段开始时，若你已受伤，你可以进行一次判定：若结果为黑色，你观看牌堆顶的X张牌（X为你已损失的体力值），然后将这些牌交给一名角色。',
  ['$nos__miji1'] = '奇谋，只在绝境中诞生！',
  ['$nos__miji2'] = '我将尽我所能！',
}

nos__miji:addEffect(fk.EventPhaseStart, {
  anim_type = "drawcard",
  can_trigger = function(skill, event, target, player, data)
    return target == player and player:hasSkill(nos__miji.name) and player:isWounded() and
      (player.phase == Player.Start or player.phase == Player.Finish)
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = nos__miji.name,
      pattern = ".|.|spade,club",
    }
    room:judge(judge)
    if judge.card.color == Card.Black then
      local cards = room:getNCards(player:getLostHp())
      U.viewCards(player, cards, nos__miji.name)
      local tos = room:askToChoosePlayers(player, {
        targets = table.map(room.alive_players, Util.IdMapper),
        min_num = 1,
        max_num = 1,
        prompt = "#nos__miji-choose",
        skill_name = nos__miji.name
      })
      room:moveCards({
        ids = cards,
        to = tos[1],
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
      })
    end
  end,
})

return nos__miji