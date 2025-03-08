local qieting = fk.CreateSkill {
  name = "qieting"
}

Fk:loadTranslationTable{
  ['qieting'] = '窃听',
  ['qieting_move'] = '将其一张装备移动给你',
  [':qieting'] = '一名其他角色的回合结束时，若其未于此回合内使用过指定另一名角色为目标的牌，你可以选择一项：将其装备区里的一张牌移动至你装备区里的相应位置；或摸一张牌。',
  ['$qieting1'] = '此人不露锋芒，断不可留！',
  ['$qieting2'] = '想欺我蔡氏，痴心妄想！'
}

qieting:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player)
    return player:hasSkill(qieting) and target ~= player and target.phase == Player.Finish and player:getMark("qieting-turn") == 0
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local choices = {"draw1"}
    if target:canMoveCardsInBoardTo(player, "e") then
      table.insert(choices, 1, "qieting_move")
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = qieting.name
    })
    if choice == "qieting_move" then
      room:askToMoveCardInBoard(player, {
        target_one = target,
        target_two = player,
        skill_name = qieting.name,
        flag = "e",
        move_from = target
      })
    else
      player:drawCards(1, qieting.name)
    end
  end,
})

qieting:addEffect(fk.CardUsing, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(qieting, true) and target ~= player and target.phase ~= Player.NotActive and data.tos
  end,
  on_refresh = function(self, event, target, player, data)
    for _, info in ipairs(data.tos) do
      for _, p in ipairs(info) do
        if p ~= data.from then
          player.room:addPlayerMark(player, "qieting-turn", 1)
          return
        end
      end
    end
  end,
})

return qieting