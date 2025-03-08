local renxin = fk.CreateSkill {
  name = "renxin"
}

Fk:loadTranslationTable{
  ['renxin'] = '仁心',
  ['#renxin-invoke'] = '仁心：你可以弃置一张装备牌，防止 %dest 受到的致命伤害',
  [':renxin'] = '每当体力值为1的一名其他角色受到伤害时，你可以弃置一张装备牌，将武将牌翻面并防止此伤害。',
  ['$renxin1'] = '仁者爱人，人恒爱之。',
  ['$renxin2'] = '有我在，别怕。',
}

renxin:addEffect(fk.DamageInflicted, {
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(renxin.name) and target ~= player and target.hp == 1 and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askToDiscard(player, {
    min_num = 1,
    max_num = 1,
    include_equip = true,
    skill_name = renxin.name,
    cancelable = true,
    pattern = ".|.|.|.|.|equip",
    prompt = "#renxin-invoke::" .. target.id
    })
    if #card > 0 then
    event:setCostData(self, card)
    return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:throwCard(event:getCostData(self), renxin.name, player, player)
    player:turnOver()
    return true
  end,
})

return renxin