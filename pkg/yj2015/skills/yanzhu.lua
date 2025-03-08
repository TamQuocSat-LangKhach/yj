local yanzhu = fk.CreateSkill {
  name = "yanzhu"
}

Fk:loadTranslationTable{
  ['yanzhu'] = '宴诛',
  ['#yanzhu-discard'] = '宴诛：弃置一张牌，或点“取消”将所有装备交给 %src（若没装备则必须弃一张牌）',
  [':yanzhu'] = '出牌阶段限一次，你可以令一名其他角色选择一项：1.弃置一张牌；2.交给你装备区内所有的牌，你失去〖宴诛〗并修改〖兴学〗为“X为你的体力上限”。',
  ['$yanzhu1'] = '不诛此权臣，朕，何以治天下？',
  ['$yanzhu2'] = '大局已定，你还是放弃吧。',
}

yanzhu:addEffect('active', {
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(yanzhu.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return false
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    local target = room:getPlayerById(to_select)
    return #selected == 0 and to_select ~= player.id and not Fk:currentRoom():getPlayerById(to_select):isNude()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local cancelable = #target.player_cards[Player.Equip] > 0
    if #room:askToDiscard(target, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = yanzhu.name,
      cancelable = cancelable,
      prompt = "#yanzhu-discard:" .. player.id
    }) == 0 and cancelable then
      room:obtainCard(player.id, target:getCardIds(Player.Equip), true, fk.ReasonGive, target.id)
      room:handleAddLoseSkills(player, "-" .. yanzhu.name, nil, true, false)
      room:setPlayerMark(player, yanzhu.name, 1)
    end
  end,
})

return yanzhu