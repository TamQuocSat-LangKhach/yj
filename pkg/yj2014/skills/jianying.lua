```lua
local jianying = fk.CreateSkill {
  name = "jianying"
}

Fk:loadTranslationTable{
  ['jianying'] = '渐营',
  ['@jianying-phase'] = '渐营',
  [':jianying'] = '每当你于出牌阶段内使用的牌与此阶段你使用的上一张牌点数或花色相同时，你可以摸一张牌。',
  ['$jianying1'] = '由缓至急，循循而进。',
  ['$jianying2'] = '事需缓图，欲速不达也。',
}

jianying:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jianying.name) and data.extra_data and data.extra_data.jianyingCheck
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, jianying.name)
  end,

  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(jianying.name, true) and player.phase == Player.Play
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if data.card.suit == Card.NoSuit then
      room:setPlayerMark(player, "@jianying-phase", 0)
    else
      local mark = player:getTableMark("@jianying-phase")
      if data.card:getSuitString(true) == mark[1] or data.card.number == mark[2] then
        data.extra_data = data.extra_data or {}
        data.extra_data.jianyingCheck = true
      end
      room:setPlayerMark(player, "@jianying-phase", {data.card:getSuitString(true), data.card.number})
    end
  end,
})

jianying:addEffect(fk.LoseSkill, {
  on_lose = function(self, player)
    if player:getMark("@jianying-phase") ~= 0 then
      player.room:setPlayerMark(player, "@jianying-phase", 0)
    end
  end,
})

return jianying
```