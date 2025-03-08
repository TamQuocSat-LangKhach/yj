local huilei = fk.CreateSkill {
  name = "huilei"
}

Fk:loadTranslationTable{
  ['huilei'] = '挥泪',
  [':huilei'] = '锁定技，杀死你的角色弃置所有牌。',
  ['$huilei1'] = '丞相视某如子，某以丞相为父。',
  ['$huilei2'] = '谡愿以死安大局。',
}

huilei:addEffect(fk.Death, {
  anim_type = "control",
  frequency = Skill.Compulsory,
  can_trigger = function(skill, event, target, player, data)
    return target == player and player:hasSkill(huilei.name, false, true) and data.damage and data.damage.from and not data.damage.from:isNude()
  end,
  on_use = function(skill, event, target, player, data)
    data.damage.from:throwAllCards("he")
  end
})

return huilei