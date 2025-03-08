local nos__faen = fk.CreateSkill {
  name = "nos__faen"
}

Fk:loadTranslationTable{
  ['nos__faen'] = '法恩',
  ['#nos__faen-invoke'] = '法恩：你可以令 %dest 摸一张牌',
  [':nos__faen'] = '每当一名角色的武将牌翻面或横置时，你可以令其摸一张牌。',
  ['$nos__faen1'] = '礼法容情，皇恩浩荡。',
  ['$nos__faen2'] = '法理有度，恩威并施。',
}

nos__faen:addEffect(fk.TurnedOver, {
  can_trigger = function(self, event, target, player)
    if player:hasSkill(nos__faen) and not target.dead then
      return true
    end
  end,
  on_cost = function(self, event, target, player)
    event:setCostData(self, {tos = {target.id}})
    return player.room:askToSkillInvoke(player, {
      skill_name = nos__faen.name,
      prompt = "#nos__faen-invoke::"..target.id
    })
  end,
  on_use = function(self, event, target, player)
    local cost_data = event:getCostData(self)
    target:drawCards(1, nos__faen.name)
  end,
})

nos__faen:addEffect(fk.ChainStateChanged, {
  can_trigger = function(self, event, target, player)
    if player:hasSkill(nos__faen) and not target.dead then
      return target.chained
    end
  end,
  on_cost = function(self, event, target, player)
    event:setCostData(self, {tos = {target.id}})
    return player.room:askToSkillInvoke(player, {
      skill_name = nos__faen.name,
      prompt = "#nos__faen-invoke::"..target.id
    })
  end,
  on_use = function(self, event, target, player)
    local cost_data = event:getCostData(self)
    target:drawCards(1, nos__faen.name)
  end,
})

return nos__faen