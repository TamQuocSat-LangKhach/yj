local zhige = fk.CreateSkill {
  name = "zhige"
}

Fk:loadTranslationTable{
  ['zhige'] = '止戈',
  ['#zhige-use'] = '止戈：使用一张【杀】，否则将装备区内一张牌交给 %src',
  ['#zhige-card'] = '止戈：将装备区内一张牌交给 %src',
  [':zhige'] = '出牌阶段限一次，若你的手牌数大于体力值，你可以令一名攻击范围包含你的其他角色选择一项：1.使用一张【杀】；2.将装备区里的一张牌交给你。',
  ['$zhige1'] = '天下和而平乱，神器宁而止戈。',
  ['$zhige2'] = '刀兵纷争既止，国运福祚绵长。',
}

zhige:addEffect('active', {
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(zhige.name) == 0 and #player.player_cards[Player.Hand] > player.hp
  end,
  card_filter = function(self, player, to_select, selected)
    return false
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getPlayerById(to_select):inMyAttackRange(player)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local use = room:askToUseCard(target, {
      skill_name = "slash",
      pattern = "Slash",
      prompt = "#zhige-use:" .. player.id,
      cancelable = true
    })
    if use then
      room:useCard(use)
    else
      if #target.player_cards[Player.Equip] > 0 then
        local card = room:askToCards(target, {
          min_num = 1,
          max_num = 1,
          include_equip = true,
          skill_name = zhige.name,
          cancelable = false,
          pattern = ".|.|.|equip",
          prompt = "#zhige-card:" .. player.id
        })
        room:obtainCard(player, card[1], true, fk.ReasonGive, target.id)
      end
    end
  end,
})

return zhige