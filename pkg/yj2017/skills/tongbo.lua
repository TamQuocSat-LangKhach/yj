local tongbo = fk.CreateSkill {
  name = "tongbo"
}

Fk:loadTranslationTable{
  ['tongbo'] = '通博',
  ['caiyong_book'] = '书',
  ['$MyCard'] = '我的牌',
  ['#tongbo-give'] = '通博：你须将所有“书”分配给任意名其他角色',
  [':tongbo'] = '摸牌阶段结束时，你可以用任意张牌替换等量的“书”，然后若你的“书”包含四种花色，你须将所有“书”分配给任意名其他角色。 ',
  ['$tongbo1'] = '读万卷书，行万里路。',
  ['$tongbo2'] = '博学而不穷，笃行而不倦。',
}

tongbo:addEffect(fk.AfterDrawNCards, {
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(tongbo.name) and #player:getPile("caiyong_book") > 0 and not player:isNude()
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local books = player:getPile("caiyong_book")
    local piles = room:askToArrangeCards(player, {
      skill_name = tongbo.name,
      card_map = {"caiyong_book", books, "$MyCard", player:getCardIds{Player.Hand, Player.Equip}},
    })
    if table.every(piles[1], function (id)
      return table.contains(books, id)
    end) then return false end
    U.swapCardsWithPile(player, piles[1], piles[2], tongbo.name, "caiyong_book")
    if player.dead then return false end
    local targets = room:getOtherPlayers(player, false)
    if #targets == 0 then return false end
    books = player:getPile("caiyong_book")
    if #books < 4 then return false end
    local suits = {1, 2, 3, 4}
    for _, id in ipairs(books) do
      table.removeOne(suits, Fk:getCardById(id).suit)
    end
    if #suits > 0 then return false end
    room:askToYiji(player, {
      cards = books,
      targets = targets,
      skill_name = tongbo.name,
      min_num = #books,
      max_num = #books,
      prompt = "#tongbo-give",
      expand_pile = "caiyong_book"
    })
  end,
})

return tongbo