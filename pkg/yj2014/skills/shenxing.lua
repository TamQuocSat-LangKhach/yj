local shenxing = fk.CreateSkill {
  name = "shenxing"
}

Fk:loadTranslationTable{
  ['shenxing'] = '慎行',
  ['#shenxing-active'] = '发动 慎行，选择要弃置的两张牌',
  [':shenxing'] = '出牌阶段，你可以弃置两张牌，然后摸一张牌。',
  ['$shenxing1'] = '审时度势，乃容万变。',
  ['$shenxing2'] = '此需斟酌一二。',
}

shenxing:addEffect('active', {
  anim_type = "drawcard",
  prompt = "#shenxing-active",
  card_num = 2,
  target_num = 0,
  can_use = Util.TrueFunc,
  card_filter = function(self, player, to_select, selected)
    return #selected < 2 and not player:prohibitDiscard(Fk:getCardById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:askToDiscard(player, {
      min_num = 2,
      max_num = 2,
      skill_name = shenxing.name
    })
    if not player.dead then
      player:drawCards(1, shenxing.name)
    end
  end
})

return shenxing