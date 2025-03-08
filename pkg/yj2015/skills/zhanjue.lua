local zhanjue = fk.CreateSkill {
  name = "zhanjue"
}

Fk:loadTranslationTable{
  ['zhanjue'] = '战绝',
  ['#zhanjue'] = '战绝：你可以将所有手牌当【决斗】使用，然后你和受伤的角色各摸一张牌',
  [':zhanjue'] = '出牌阶段，你可以将所有手牌当【决斗】使用，然后你和受伤的角色各摸一张牌。若你此法摸过两张或更多的牌，则本阶段〖战绝〗失效。',
  ['$zhanjue1'] = '成败在此一举，杀！',
  ['$zhanjue2'] = '此刻，唯有死战，安能言降！',
}

zhanjue:addEffect('viewas', {
  anim_type = "offensive",
  card_num = 0,
  min_target_num = 1,
  prompt = "#zhanjue",
  card_filter = function(self, player, to_select, selected)
    return false
  end,
  -- target_filter = function(self, player, to_select, selected, selected_cards)
  --   local card = Fk:cloneCard("duel")
  --   card:addSubcards(player:getCardIds(Player.Hand))
  --   return player:canUseTo(card, Fk:currentRoom():getPlayerById(to_select))
  -- end,
  view_as = function(self, player, cards)
    local card = Fk:cloneCard("duel")
    card:addSubcards(player:getCardIds(Player.Hand))
    return card
  end,
  after_use = function(zhanjue, player, use)
    local room = player.room
    if not player.dead then
      player:drawCards(1, zhanjue.name)
      room:addPlayerMark(player, "zhanjue-phase", 1)
    end
    if use.damageDealt then
      for _, p in ipairs(room.alive_players) do
        if use.damageDealt[p.id] then
          p:drawCards(1, zhanjue.name)
          if p == player then
            room:addPlayerMark(player, "zhanjue-phase", 1)
          end
        end
      end
    end
  end,
  enabled_at_play = function(zhanjue, player)
    return player:getMark("zhanjue-phase") < 2 and not player:isKongcheng()
  end
})

return zhanjue