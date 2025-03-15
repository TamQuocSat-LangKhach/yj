local jiefan = fk.CreateSkill {
  name = "jiefan"
}

Fk:loadTranslationTable{
  ['jiefan'] = '解烦',
  ['jiefan_target'] = '解烦目标',
  ['jiefaned'] = '被解烦',
  ['#jiefan-discard'] = '解烦：弃置一张武器牌，否则 %dest 摸一张牌',
  [':jiefan'] = '限定技，出牌阶段，你可以选择一名角色，然后令攻击范围内有该角色的所有角色各选择一项：1.弃置一张武器牌；2.令其摸一张牌。',
  ['$jiefan1'] = '公且放心，这里有我。',
  ['$jiefan2'] = '排愁消烦忧，祛害避凶邪。',
}

jiefan:addEffect('active', {
  anim_type = "drawcard",
  card_num = 0,
  target_num = 1,
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(jiefan.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  target_tip = function (skill, player, to_select, selected, selected_cards, card, selectable, extra_data)
    if #selected == 0 then return end
    if to_select == selected[1] then
    return "jiefan_target"
    else
    local p = Fk:currentRoom():getPlayerById(to_select)
    local target = Fk:currentRoom():getPlayerById(selected[1])
    if p:inMyAttackRange(target) then
      return { {content = "jiefaned", type = "warning"} }
    end
    end
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    for _, p in ipairs(room:getOtherPlayers(target)) do
    if p:inMyAttackRange(target) then
      if #room:askToDiscard(p, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = jiefan.name,
      cancelable = true,
      pattern = ".|.|.|.|.|weapon",
      prompt = "#jiefan-discard::" .. target.id
      }) == 0 then
      target:drawCards(1, jiefan.name)
      end
    end
    end
  end,
})

return jiefan