local rouxian = fk.CreateSkill {
  name = "rouxian"
}

Fk:loadTranslationTable{
  ['rouxian'] = '柔弦',
  ['#rouxian-invoke'] = '柔弦：你可以令 %src 回复1点体力并弃置一张装备牌',
  ['qingxian_recover'] = '回复1点体力并弃置一张装备牌',
  [':rouxian'] = '当你受到伤害后，你可以令伤害来源回复1点体力并弃置一张装备牌。',
  ['$rouxian'] = '君子以琴会友，以瑟辅人。',
}

rouxian:addEffect(fk.Damaged, {
  can_trigger = function(skill, event, target, player, data)
    return player:hasSkill(rouxian.name) and target == player and data.from and not data.from.dead
  end,
  on_cost = function (skill, event, target, player, data)
    event:setCostData(player, {tos = {data.from.id}})
    return player.room:askToSkillInvoke(player, {
      skill_name = rouxian.name,
      prompt = "#rouxian-invoke:"..data.from.id
    })
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    doQingxian(room, data.from, player, "qingxian_recover", rouxian.name)
  end,
})

return rouxian