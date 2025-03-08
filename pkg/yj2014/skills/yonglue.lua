local yonglue = fk.CreateSkill {
  name = "yonglue"
}

Fk:loadTranslationTable{
  ['yonglue'] = '勇略',
  ['#yonglue-invoke'] = '勇略：你可以弃置 %dest 判定区一张牌，视为对其使用【杀】',
  [':yonglue'] = '你攻击范围内的一名其他角色的判定阶段开始时，你可以弃置其判定区里的一张牌，视为对该角色使用【杀】，若此【杀】未造成伤害，你摸一张牌。',
  ['$yonglue1'] = '不必从言，自有主断！',
  ['$yonglue2'] = '非常之机，当行非常之计！',
}

yonglue:addEffect(fk.EventPhaseStart, {
  can_trigger = function(skill, event, target, player)
  return player:hasSkill(yonglue.name) and target.phase == Player.Judge and #target:getCardIds("j") > 0 and player:inMyAttackRange(target)
  end,
  on_cost = function(skill, event, target, player)
  return player.room:askToSkillInvoke(player, {
    skill_name = yonglue.name,
    prompt = "#yonglue-invoke::" .. target.id
  })
  end,
  on_use = function(skill, event, target, player)
  local room = player.room
  room:doIndicate(player.id, {target.id})
  local card = room:askToChooseCard(player, {
    target = target,
    flag = "j",
    skill_name = yonglue.name
  })
  room:throwCard({card}, yonglue.name, target, player)
  if player.dead or target.dead then return end
  local use = {
    from = player.id,
    tos = {{target.id}},
    card = Fk:cloneCard("slash"),
    extraUse = true,
  }
  use.card.skillName = yonglue.name
  room:useCard(use)
  if not player.dead and not use.damageDealt then
    player:drawCards(1, yonglue.name)
  end
  end,
})

return yonglue