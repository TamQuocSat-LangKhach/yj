local xianzhou = fk.CreateSkill {
  name = "xianzhou"
}

Fk:loadTranslationTable{
  ['xianzhou'] = '献州',
  ['#xianzhou-choose'] = '献州：对你攻击范围内的至多%arg名角色各造成1点伤害，或点“取消”令 %src 回复体力',
  [':xianzhou'] = '限定技，出牌阶段，你可以将装备区里的所有牌交给一名其他角色，然后该角色选择一项：1.令你回复X点体力；2.对其攻击范围内的至多X名角色各造成1点伤害（X为你以此法交给该角色的牌的数量）。',
  ['$xianzhou1'] = '献荆襄九郡，图一世之安。',
  ['$xianzhou2'] = '丞相携天威而至，吾等安敢不降。',
}

xianzhou:addEffect('active', {
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  frequency = Skill.Limited,

  can_use = function(self, player)
  return player:usedSkillTimes(xianzhou.name, Player.HistoryGame) == 0 and #player.player_cards[Player.Equip] > 0
  end,

  card_filter = function(self, player, to_select, selected)
  return false
  end,

  target_filter = function(self, player, to_select, selected)
  return #selected == 0 and to_select ~= player.id
  end,

  on_use = function(self, room, effect)
  local player = room:getPlayerById(effect.from)
  local target = room:getPlayerById(effect.tos[1])
  local n = #player.player_cards[Player.Equip]
  room:obtainCard(target, player:getCardIds(Player.Equip), false, fk.ReasonGive, player.id)

  local targets = table.map(table.filter(room:getOtherPlayers(target), function(p)
    return target:inMyAttackRange(p) end), Util.IdMapper)

  if #targets > 0 then
    local tos = room:askToChoosePlayers(target, {
    targets = targets,
    min_num = 1,
    max_num = n,
    prompt = "#xianzhou-choose:"..player.id.."::"..n,
    skill_name = xianzhou.name,
    cancelable = true
    })
    if #tos > 0 then
    for _, p in ipairs(tos) do
      room:damage{
      from = target,
      to = p,
      damage = 1,
      skillName = xianzhou.name,
      }
    end
    else
    if player:isWounded() then
      room:recover({
      who = player,
      num = math.min(n, player:getLostHp()),
      recoverBy = target,
      skillName = xianzhou.name
      })
    end
    end
  end
  end,
})

return xianzhou