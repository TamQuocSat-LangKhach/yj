```lua
local huaiyi = fk.CreateSkill {
  name = "huaiyi"
}

Fk:loadTranslationTable{
  ['huaiyi'] = '怀异',
  ['#huaiyi-choose'] = '怀异：你可以获得至多%arg名角色各一张牌',
  [':huaiyi'] = '出牌阶段限一次，你可以展示所有手牌，若其中包含两种颜色，则你弃置其中一种颜色的牌，然后获得至多X名角色的各一张牌（X为你以此法弃置的手牌数）。若你获得的牌大于一张，则你失去1点体力。',
  ['$huaiyi1'] = '此等小利，焉能安吾雄心？',
  ['$huaiyi2'] = '一生纵横，怎可对他人称臣！',
}

huaiyi:addEffect('active', {
  anim_type = "control",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(huaiyi.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cards = player.player_cards[Player.Hand]
    player:showCards(cards)
    local colors = {}
    for _, id in ipairs(cards) do
      if Fk:getCardById(id).color ~= Card.NoColor then
        table.insertIfNeed(colors, Fk:getCardById(id):getColorString())
      end
    end
    if #colors < 2 then return end
    local color = room:askToChoice(player, {choices = colors, skill_name = huaiyi.name})
    local throw = {}
    for _, id in ipairs(cards) do
      if Fk:getCardById(id):getColorString() == color and not player:prohibitDiscard(Fk:getCardById(id)) then
        table.insert(throw, id)
      end
    end
    if #throw == 0 then return end
    room:throwCard(throw, huaiyi.name, player, player)
    if player.dead then return end
    local targets = room:askToChoosePlayers(player, {targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
      return (not p:isNude()) 
    end), Util.IdMapper), min_num = 1, max_num = #throw, skill_name = huaiyi.name, prompt = "#huaiyi-choose:::"..tostring(#throw)})
    if #targets > 0 then
      room:sortPlayersByAction(targets)
      local n = 0
      for _, p in ipairs(targets) do
        if player.dead then return end
        local to = room:getPlayerById(p)
        if not to:isNude() then
          local id = room:askToChooseCard(player, {target = to, flag = "he", skill_name = huaiyi.name})
          n = n + 1
          room:moveCardTo(id, Card.PlayerHand, player, fk.ReasonPrey, huaiyi.name, nil, false, player.id)
        end
      end
      if n > 1 and not player.dead then
        room:loseHp(player, 1, huaiyi.name)
      end
    end
  end,
})

return huaiyi
```