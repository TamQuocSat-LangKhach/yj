```lua
local ganlu = fk.CreateSkill {
  name = "ganlu"
}

Fk:loadTranslationTable{
  ['ganlu'] = '甘露',
  ['#ganlu'] = '甘露：选择装备区内牌数之差不大于%arg的两名角色，交换其装备区内的牌',
  [':ganlu'] = '出牌阶段限一次，你可以选择装备区内牌数之差不大于X的两名角色，交换其装备区内的牌（X为你已损失体力值）。',
  ['$ganlu1'] = '男婚女嫁，须当交换文定之物。',
  ['$ganlu2'] = '此真乃吾之佳婿也。',
}

ganlu:addEffect('active', {
  anim_type = "control",
  target_num = 2,
  card_num = 0,
  prompt = function(skill, player)
    return "#ganlu:::"..player:getLostHp()
  end,
  can_use = function(skill, player)
    return player:usedSkillTimes(ganlu.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(skill, player, to_select, selected)
    if #selected == 0 then
      return #Fk:currentRoom():getPlayerById(to_select).player_cards[Player.Equip] > 0
    elseif #selected == 1 then
      local target1 = Fk:currentRoom():getPlayerById(to_select)
      local target2 = Fk:currentRoom():getPlayerById(selected[1])
      return math.abs(#target1:getCardIds("e") - #target2:getCardIds("e")) <= player:getLostHp()
    else
      return false
    end
  end,
  on_use = function(skill, room, effect)
    local player = room:getPlayerById(effect.from)
    local target1 = room:getPlayerById(effect.tos[1])
    local target2 = room:getPlayerById(effect.tos[2])
    U.swapCards(room, player, target1, target2, target1:getCardIds("e"), target2:getCardIds("e"), ganlu.name, Card.PlayerEquip)
  end,
})

return ganlu
```