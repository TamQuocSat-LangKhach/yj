local jixiann = fk.CreateSkill {
  name = "jixiann"
}

Fk:loadTranslationTable{
  ['jixiann'] = '激弦',
  ['#jixiann-invoke'] = '激弦：你可以令 %src 失去1点体力并使用随机装备牌',
  ['qingxian_losehp'] = '失去1点体力并随机使用牌堆一张装备牌',
  [':jixiann'] = '当你受到伤害后，你可以令伤害来源失去1点体力并随机使用牌堆一张装备牌。',
  ['$jixiann'] = '一弹一拨，铿锵有力！',
}

jixiann:addEffect(fk.Damaged, {
  can_trigger = function(skill, event, target, player, data)
    return player:hasSkill(skill.name) and target == player and data.from and not data.from.dead
  end,
  on_cost = function (skill, event, target, player, data)
    event:setCostData(player, {tos = {data.from.id}})
    return player.room:askToSkillInvoke(player, {
    skill_name = skill.name,
    prompt = "#jixiann-invoke:"..data.from.id
    })
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    doQingxian(room, data.from, player, "qingxian_losehp", skill.name)
  end,
})

return jixiann