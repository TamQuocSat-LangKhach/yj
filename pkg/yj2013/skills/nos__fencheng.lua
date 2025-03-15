local nos__fencheng = fk.CreateSkill {
  name = "nos__fencheng"
}

Fk:loadTranslationTable{
  ['nos__fencheng'] = '焚城',
  ['#nos__fencheng-discard'] = '焚城：你需弃置%arg张牌，否则受到1点火焰伤害',
  [':nos__fencheng'] = '限定技，出牌阶段，你可令所有其他角色依次选择一项：弃置X张牌，或受到1点火焰伤害。（X为该角色装备区里牌的数量且至少为1）',
  ['$nos__fencheng1'] = '我要这满城的人都来给你陪葬。',
  ['$nos__fencheng2'] = '一把火烧他个精光吧！诶啊哈哈哈哈哈~',
}

nos__fencheng:addEffect('active', {
  anim_type = "offensive",
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(nos__fencheng.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = room:getOtherPlayers(player)
    for _, target in ipairs(targets) do
      local length = math.max(1, #target.player_cards[Player.Equip])
      local cards = room:askToDiscard(target, {
        min_num = length,
        max_num = length,
        include_equip = true,
        skill_name = nos__fencheng.name,
        cancelable = true,
        prompt = "#nos__fencheng-discard:::" .. tostring(length),
      })
      if #cards == 0 then
        room:damage{
          from = player,
          to = target,
          damage = 1,
          damageType = fk.FireDamage,
          skillName = nos__fencheng.name,
        }
      end
    end
  end,
})

return nos__fencheng