local faen = fk.CreateSkill {
  name = "faen"
}

Fk:loadTranslationTable{
  ['faen'] = '法恩',
  ['#faen-invoke'] = '法恩：你可以令 %dest 摸一张牌',
  [':faen'] = '当一名角色的武将牌翻至正面朝上或横置后，你可以令其摸一张牌。',
  ['$faen1'] = '王法威仪，恩泽天下。',
  ['$faen2'] = '法外有情，恩威并举。',
}

faen:addEffect(fk.TurnedOver, {
  can_trigger = function(self, event, target, player)
    if player:hasSkill(skill.name) and not target.dead then
      return target.faceup
    end
  end,
  on_cost = function(self, event, target, player)
    local room = player.room
    if room:askToSkillInvoke(player, {
        skill_name = skill.name,
        prompt = "#faen-invoke::" .. target.id
      }) then
      event:setCostData(skill, {tos = {target.id}})
      return true
    end
  end,
  on_use = function(self, event, target, player)
    target:drawCards(1, faen.name)
  end,
})

faen:addEffect(fk.ChainStateChanged, {
  can_trigger = function(self, event, target, player)
    if player:hasSkill(skill.name) and not target.dead then
      return target.chained
    end
  end,
  on_cost = function(self, event, target, player)
    local room = player.room
    if room:askToSkillInvoke(player, {
        skill_name = skill.name,
        prompt = "#faen-invoke::" .. target.id
      }) then
      event:setCostData(skill, {tos = {target.id}})
      return true
    end
  end,
  on_use = function(self, event, target, player)
    target:drawCards(1, faen.name)
  end,
})

return faen