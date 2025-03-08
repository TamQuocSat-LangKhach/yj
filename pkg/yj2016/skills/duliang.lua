local duliang = fk.CreateSkill {
  name = "duliang"
}

Fk:loadTranslationTable{
  ['duliang'] = '督粮',
  ['#duliang'] = '督粮：获得一名其他角色一张牌，然后令其获得基本牌或其下个摸牌阶段多摸一张牌',
  ['duliang_view'] = '其观看牌堆顶的两张牌，获得其中的基本牌',
  ['duliang_draw'] = '其下个摸牌阶段额外摸一张牌',
  ['#duliang-choice'] = '督粮：选择令 %dest 执行的一项',
  ['@duliang'] = '督粮',
  ['#duliang_trigger'] = '督粮',
  [':duliang'] = '出牌阶段限一次，你可以获得一名其他角色一张牌，然后选择一项：1.其观看牌堆顶的两张牌，获得其中的基本牌；2.其下个摸牌阶段额外摸一张牌。',
  ['$duliang1'] = '粮草已到，请将军验看。',
  ['$duliang2'] = '告诉丞相，山路难走！请宽限几天。',
}

-- 主动技
duliang:addEffect('active', {
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  prompt = "#duliang",
  can_use = function(self, player)
  return player:usedSkillTimes(duliang.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
  return false
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
  return #selected == 0 and to_select ~= player.id and not Fk:currentRoom():getPlayerById(to_select):isNude()
  end,
  on_use = function(self, room, effect)
  local player = room:getPlayerById(effect.from)
  local target = room:getPlayerById(effect.tos[1])
  local card = room:askToChooseCard(player, {
    target = target,
    flag = "he",
    skill_name = duliang.name
  })
  room:obtainCard(player.id, card, false, fk.ReasonPrey, player.id, duliang.name)
  if player.dead or target.dead then return end
  local choice = room:askToChoice(player, {
    choices = {"duliang_view", "duliang_draw"},
    skill_name = duliang.name,
    prompt = "#duliang-choice::" .. target.id
  })
  if choice == "duliang_view" then
    local cards = room:getNCards(2)
    U.viewCards(target, cards, duliang.name)
    for i = #cards, 1, -1 do
    local id = cards[i]
    if Fk:getCardById(id).type ~= Card.TypeBasic then
      table.remove(cards, i)
    end
    end
    if #cards > 0 then
    room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonPrey, duliang.name, "", false)
    end
  else
    room:addPlayerMark(target, "@duliang", 1)
  end
  end,
})

-- 触发技
duliang:addEffect(fk.DrawNCards, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
  return target == player and player:getMark("@duliang") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
  data.n = data.n + player:getMark("@duliang")
  player.room:setPlayerMark(player, "@duliang", 0)
  end,
})

return duliang