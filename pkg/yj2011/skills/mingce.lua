```lua
local mingce = fk.CreateSkill {
  name = "mingce"
}

Fk:loadTranslationTable{
  ['mingce'] = '明策',
  ['#mingce'] = '明策：交给一名角色一张装备牌或【杀】，其选择视为对你指定的角色使用【杀】或摸一张牌',
  ['#mingce-choose'] = '明策：选择 %dest 视为使用【杀】的目标',
  ['mingce_slash'] = '视为对%dest使用【杀】',
  [':mingce'] = '出牌阶段限一次，你可以交给一名其他角色一张装备牌或【杀】，其选择一项：1.视为对其攻击范围内一名你指定的角色使用一张【杀】；2.摸一张牌。',
  ['$mingce1'] = '如此，霸业可图也。',
  ['$mingce2'] = '如此，一击可擒也。',
}

mingce:addEffect('active', {
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#mingce",
  can_use = function(self, player)
    return player:usedSkillTimes(mingce.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and (Fk:getCardById(to_select).trueName == "slash" or Fk:getCardById(to_select).type == Card.TypeEquip)
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:obtainCard(target.id, Fk:getCardById(effect.cards[1]), false, fk.ReasonGive, player.id)
    if player.dead or target.dead then return end
    local targets = table.map(table.filter(room:getOtherPlayers(target), function(p)
      return target:inMyAttackRange(p) 
    end), Util.IdMapper)
    if #targets == 0 then
      target:drawCards(1, mingce.name)
    else
      local to = room:askToChoosePlayers(player, {
        targets = targets,
        min_num = 1,
        max_num = 1,
        prompt = "#mingce-choose::" .. target.id,
        skill_name = mingce.name,
        cancelable = false,
        no_indicate = true
      })
      to = room:getPlayerById(to[1])
      room:doIndicate(target.id, {to.id})
      local choice = room:askToChoice(target, {
        choices = {"mingce_slash::" .. to.id, "draw1"},
        skill_name = mingce.name,
      })
      if choice == "draw1" then
        target:drawCards(1, mingce.name)
      else
        room:useVirtualCard("slash", nil, target, to, mingce.name, true)
      end
    end
  end,
})

return mingce
```