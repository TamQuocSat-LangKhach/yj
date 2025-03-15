```lua
local qinwang = fk.CreateSkill {
  name = "qinwang$"
}

Fk:loadTranslationTable{
  ['#qinwang'] = '勤王：你可以弃置一张牌，然后令其他蜀势力角色选择是否打出一张【杀】（视为由你使用或打出）',
  ['#qinwang-ask'] = '勤王: 你可打出一张【杀】，视为 %src 使用或打出，若如此做，你摸一张牌',
}

qinwang:addEffect('viewas', {
  prompt = "#qinwang",
  mute = true,
  anim_type = "defensive",
  pattern = "slash",
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and not player:prohibitDiscard(Fk:getCardById(to_select))
  end,
  before_use = function(self, player, use)
    local room = player.room
    if use.card.extra_data and type(use.card.extra_data.qinwangCards) == "table" and #use.card.extra_data.qinwangCards > 0 then
      room:notifySkillInvoked(player, skill.name)
      player:broadcastSkillInvoke(skill.name)
      room:throwCard(use.card.extra_data.qinwangCards, skill.name, player, player)
      if use.tos then
        room:doIndicate(player.id, TargetGroup:getRealTargets(use.tos))
      end

      for _, p in ipairs(room:getOtherPlayers(player)) do
        if p.kingdom == "shu" then
          local cardResponded = room:askToResponse(p, {
            pattern = "slash",
            skill_name = "#qinwang-ask:" .. player.id,
            cancelable = true
          })
          if cardResponded then
            room:responseCard({
              from = p.id,
              card = cardResponded,
              skipDrop = true,
            })

            use.card = cardResponded
            use.extra_data = use.extra_data or {}
            use.extra_data.qinwangUser = p.id
            return
          end
        end
      end

      room:setPlayerMark(player, "qinwang-failed-phase", 1)
    end
    return skill.name
  end,
  after_use = function(self, player, use)
    if use.extra_data and use.extra_data.qinwangUser then
      local p = player.room:getPlayerById(use.extra_data.qinwangUser)
      if p and not p.dead then
        p:drawCards(1, skill.name)
      end
    end
  end,
  view_as = function(self, player, cards)
    if #cards < 1 then return end
    local c = Fk:cloneCard("slash")
    c.skillName = skill.name
    c.extra_data = c.extra_data or {}
    c.extra_data.qinwangCards = cards
    return c
  end,
  enabled_at_play = function(self, player)
    return player:getMark("qinwang-failed-phase") == 0 and not player:isNude() and
      table.find(Fk:currentRoom().alive_players, function(p) return p ~= player and p.kingdom == "shu" end)
  end,
  enabled_at_response = function(self, player)
    return player:getMark("qinwang-failed-phase") == 0 and not player:isNude() and
      table.find(Fk:currentRoom().alive_players, function(p) return p ~= player and p.kingdom == "shu" end)
  end,
})

return qinwang
```