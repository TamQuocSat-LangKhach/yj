local anxu = fk.CreateSkill {
  name = "anxu"
}

Fk:loadTranslationTable{
  ['anxu'] = '安恤',
  ['#anxu-active'] = '发动 安恤，选择两名手牌数不相等的其他角色',
  [':anxu'] = '出牌阶段限一次，你可以选择两名手牌数不相等的其他角色，令其中手牌少的角色获得手牌多的角色一张手牌（正面朝上移动），若此牌的花色不为♠，你摸一张牌。',
  ['$anxu1'] = '和鸾雍雍，万福攸同。',
  ['$anxu2'] = '君子乐胥，万邦之屏。',
}

anxu:addEffect('active', {
  prompt = "#anxu-active",
  anim_type = "control",
  target_num = 2,
  card_num = 0,
  can_use = function(skill, player)
    return player:usedSkillTimes(anxu.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(skill, player, to_select, selected)
    if #selected > 1 or to_select == player.id then return false end
    if #selected == 0 then
      return true
    elseif #selected == 1 then
      local target1 = Fk:currentRoom():getPlayerById(to_select)
      local target2 = Fk:currentRoom():getPlayerById(selected[1])
      return target1:getHandcardNum() ~= target2:getHandcardNum()
    else
      return false
    end
  end,
  on_use = function(skill, room, effect)
    local target1 = room:getPlayerById(effect.tos[1])
    local target2 = room:getPlayerById(effect.tos[2])
    local from, to
    if target1:getHandcardNum() < target2:getHandcardNum() then
      from = target1
      to = target2
    else
      from = target2
      to = target1
    end
    local card = room:askToChooseCard(effect.from, {
      target = to,
      flag = "h",
      skill_name = anxu.name
    })
    room:obtainCard(from.id, card, true, fk.ReasonPrey)
    if Fk:getCardById(card).suit ~= Card.Spade then
      local player = room:getPlayerById(effect.from)
      if not player.dead then
        player:drawCards(1, anxu.name)
      end
    end
  end,
})

return anxu