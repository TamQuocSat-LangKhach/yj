local zhongjian = fk.CreateSkill {
  name = "zhongjian"
}

Fk:loadTranslationTable{
  ['zhongjian'] = '忠鉴',
  ['zhongjian_throw'] = '弃置%src一张牌',
  [':zhongjian'] = '出牌阶段限一次，你可以展示一张手牌，然后展示手牌数大于体力值的一名其他角色X张手牌（X为其手牌数和体力值之差）。若其以此法展示的牌与你展示的牌：有颜色相同的，你摸一张牌或弃置其一张牌；有点数相同的，本回合此技能改为“出牌阶段限两次”；均不同且你手牌上限大于0，你的手牌上限-1。',
  ['$zhongjian1'] = '浊世风云变幻，当以明眸洞察。',
  ['$zhongjian2'] = '心中自有明镜，可鉴奸佞忠良。',
}

zhongjian:addEffect('active', {
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(zhongjian.name, Player.HistoryPhase) < (1 + player:getMark("zhongjian_times-turn"))
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  target_filter = function(self, player, to_select, selected)
    if #selected == 0 and player.id ~= to_select then
      local target = Fk:currentRoom():getPlayerById(to_select)
      return target:getHandcardNum() > target.hp
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    player:showCards(effect.cards)
    local x = target:getHandcardNum() - target.hp
    if x <= 0 or player.dead then return end
    local show = room:askToChooseCards(player, {
      min = x,
      max = x,
      target = target,
      flag = "h",
      skill_name = zhongjian.name
    })
    target:showCards(show)
    if player.dead then return end
    local card = Fk:getCardById(effect.cards[1])
    local hasSame
    if table.find(show, function(id) return Fk:getCardById(id).color == card.color end) then
      local choices = {"draw1"}
      if not target:isNude() then table.insert(choices, "zhongjian_throw:"..target.id) end
      if room:askToChoice(player, {choices = choices, skill_name = zhongjian.name}) == "draw1" then
        player:drawCards(1, zhongjian.name)
      else
        local cid = room:askToChooseCard(player, {
          target = target,
          flag = "he",
          skill_name = zhongjian.name
        })
        room:throwCard({cid}, zhongjian.name, target, player)
      end
      hasSame = true
    end
    if table.find(show, function(id) return Fk:getCardById(id).number == card.number end) then
      room:setPlayerMark(player, "zhongjian_times-turn", 1)
      hasSame = true
    end
    if not hasSame and player:getMaxCards() > 0 then
      room:addPlayerMark(player, MarkEnum.MinusMaxCards, 1)
      room:broadcastProperty(player, "MaxCards")
    end
  end,
})

return zhongjian