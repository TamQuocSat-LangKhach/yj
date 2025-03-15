local sidi = fk.CreateSkill {
  name = "sidi"
}

Fk:loadTranslationTable{
  ['sidi'] = '司敌',
  ['#sidi-invoke'] = '司敌：你可以将一张“司敌”牌置入弃牌堆，令 %dest 本阶段使用【杀】次数上限-1',
  [':sidi'] = '每当你使用或其他角色在你的回合内使用【闪】时，你可以将牌堆顶的一张牌正面向上置于你的武将牌上；一名其他角色的出牌阶段开始时，你可以将你武将牌上的一张牌置入弃牌堆，然后该角色本阶段可使用【杀】的次数上限-1。',
  ['$sidi1'] = '筑城固守，司敌备战。',
  ['$sidi2'] = '徒手制敌，能奈我何？'
}

sidi:addEffect(fk.CardUseFinished, {
  can_trigger = function(self, event, target, player, data)
    return data.card.name == "jink" and (target == player or player.phase ~= Player.NotActive)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    return room:askToSkillInvoke(player, {skill_name = skill.name})
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:addToPile(skill.name, room:getNCards(1), true, skill.name)
  end,
})

sidi:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
  return target ~= player and target.phase == Player.Play and #player:getPile(skill.name) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToCards(player, {
    min_num = 1,
    max_num = 1,
    include_equip = false,
    skill_name = skill.name,
    pattern = ".|.|.|sidi|.|.",
    prompt = "#sidi-invoke::" .. target.id
    })
    if #card > 0 then
    event:setCostData(skill, card)
    return true
    end
  end,
  on_use = function(self, event, target, player, data)
  local room = player.room
  room:doIndicate(player.id, {target.id})
  room:moveCards({
    from = player.id,
    ids = event:getCostData(skill),
    toArea = Card.DiscardPile,
    moveReason = fk.ReasonPutIntoDiscardPile,
    skillName = skill.name,
    specialName = skill.name,
  })
  target:addCardUseHistory("slash", 1)
  end,
})

return sidi