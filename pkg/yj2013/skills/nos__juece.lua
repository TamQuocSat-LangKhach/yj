local nos__juece = fk.CreateSkill {
  name = "nos__juece"
}

Fk:loadTranslationTable{
  ['nos__juece'] = '绝策',
  ['#nos__juece-invoke'] = '绝策：你可以对 %dest 造成1点伤害',
  ['#nos__juece-choose'] = '绝策：你可以对这些角色造成1点伤害',
  [':nos__juece'] = '在你的回合内，一名角色失去最后的手牌时，你可以对其造成1点伤害。',
  ['$nos__juece1'] = '我，最喜欢落井下石。',
  ['$nos__juece2'] = '一无所有？那就拿命来填！',
}

nos__juece:addEffect(fk.AfterCardsMove, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(nos__juece.name) and player.phase ~= Player.NotActive then
      for _, move in ipairs(data) do
        if move.from and player.room:getPlayerById(move.from):isKongcheng() and not player.room:getPlayerById(move.from).dead then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              return true
            end
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local targets = {}
    for _, move in ipairs(data) do
      if move.from and player.room:getPlayerById(move.from):isKongcheng() and not player.room:getPlayerById(move.from).dead then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            table.insertIfNeed(targets, move.from)
          end
        end
      end
    end
    if #targets > 0 then
      self:doCost(event, target, player, targets)
    end
  end,
  on_cost = function(self, event, target, player, data)
    if #data == 1 then
      if player.room:askToSkillInvoke(player, { skill_name = nos__juece.name, prompt = "#nos__juece-invoke::"..data[1] }) then
        event:setCostData(self, data)
        return true
      end
    else
      local tos = player.room:askToChoosePlayers(player, {
        targets = data,
        min_num = 1,
        max_num = 999,
        prompt = "#nos__juece-choose",
        skill_name = nos__juece.name,
        cancelable = true
      })
      if #tos > 0 then
        event:setCostData(self, tos)
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.simpleClone(event:getCostData(self))
    room:doIndicate(player.id, targets)
    for _, id in ipairs(targets) do
      local p = room:getPlayerById(id)
      if not p.dead then
        room:damage{
          from = player,
          to = p,
          damage = 1,
          skillName = nos__juece.name,
        }
      end
    end
  end,
})

return nos__juece