local duodao = fk.CreateSkill {
  name = "duodao"
}

Fk:loadTranslationTable{
  ['duodao'] = '夺刀',
  ['#duodao-invoke'] = '夺刀：你可以弃置一张牌，若%dest装备区有武器牌则获得之',
  ['#duodao-discard'] = '夺刀：你可以弃置一张牌',
  [':duodao'] = '当你受到【杀】造成的伤害后，你可以弃置一张牌，然后获得伤害来源装备区里的武器牌。',
  ['$duodao1'] = '这刀岂是你配用的？',
  ['$duodao2'] = '夺敌兵刃，如断其臂！'
}

duodao:addEffect(fk.Damaged, {
  can_trigger = function(skill, event, target, player, data)
    return target == player and player:hasSkill(duodao.name) and data.card and data.card.trueName == "slash" and not player:isNude()
  end,
  on_cost = function(skill, event, target, player, data)
    local prompt
    if data.from and not data.from.dead then
      prompt = "#duodao-invoke::"..data.from.id
    else
      prompt = "#duodao-discard"
    end
    local card = player.room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = duodao.name,
      cancelable = true,
      pattern = ".",
      prompt = prompt,
      skip = true
    })
    if #card > 0 then
      event:setCostData(skill, card)
      return true
    end
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(skill), duodao.name, player, player)
    local from = data.from
    if not from or from.dead or player.dead then return end
    local weapon = from:getEquipment(Card.SubtypeWeapon)
    if weapon then
      room:obtainCard(player.id, weapon, true, fk.ReasonPrey)
    end
  end
})

return duodao