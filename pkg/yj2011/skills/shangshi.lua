```lua
local shangshi = fk.CreateSkill {
  name = "shangshi"
}

Fk:loadTranslationTable{
  ['shangshi'] = '伤逝',
  [':shangshi'] = '当你的手牌数小于你已损失的体力值时，你可以将手牌补至已损失体力值。',
  ['$shangshi1'] = '无情者伤人，有情者自伤。',
  ['$shangshi2'] = '自损八百，可伤敌一千。',
}

shangshi:addEffect(fk.HpChanged, {
  can_trigger = function(skill, event, target, player)
  if player:hasSkill(skill.name) and player:getHandcardNum() < player:getLostHp() then
    return target == player
  end
  end,
  on_use = function(skill, event, target, player)
  local lost_hp = player:getLostHp()
  local handcards_num = player:getHandcardNum()
  if lost_hp > handcards_num then
    room:askToDrawCards(player, {
      num = lost_hp - handcards_num,
      skill_name = skill.name
    })
  end
  end,
})

shangshi:addEffect(fk.MaxHpChanged, {
  can_trigger = function(skill, event, target, player)
  if player:hasSkill(skill.name) and player:getHandcardNum() < player:getLostHp() then
    return target == player
  end
  end,
  on_use = function(skill, event, target, player)
  local lost_hp = player:getLostHp()
  local handcards_num = player:getHandcardNum()
  if lost_hp > handcards_num then
    room:askToDrawCards(player, {
      num = lost_hp - handcards_num,
      skill_name = skill.name
    })
  end
  end,
})

shangshi:addEffect(fk.AfterCardsMove, {
  can_trigger = function(skill, event, target, player, data)
  if player:hasSkill(skill.name) and player:getHandcardNum() < player:getLostHp() then
    for _, move in ipairs(data) do
    if move.from == player.id then
      for _, info in ipairs(move.moveInfo) do
      if info.fromArea == Card.PlayerHand then
        return true
      end
      end
    end
    end
  end
  end,
  on_use = function(skill, event, target, player)
  local lost_hp = player:getLostHp()
  local handcards_num = player:getHandcardNum()
  if lost_hp > handcards_num then
    room:askToDrawCards(player, {
      num = lost_hp - handcards_num,
      skill_name = skill.name
    })
  end
  end,
})

return shangshi
```