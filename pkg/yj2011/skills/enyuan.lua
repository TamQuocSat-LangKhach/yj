```lua
local enyuan = fk.CreateSkill {
  name = "enyuan"
}

Fk:loadTranslationTable{
  ['enyuan'] = '恩怨',
  ['#enyuan1-invoke'] = '恩怨：是否令 %dest 摸一张牌？',
  ['#enyuan2-invoke'] = '恩怨：你可以令 %dest 选择交给你一张手牌或失去1点体力',
  ['#enyuan-give'] = '恩怨：你需交给 %src 一张手牌，否则失去1点体力',
  [':enyuan'] = '当你获得一名其他角色两张或更多的牌时，可令其摸一张牌；当你受到1点伤害后，你可以令伤害来源选择一项：交给你一张手牌，或失去1点体力。',
  ['$enyuan1'] = '报之以李，还之以桃。',
  ['$enyuan2'] = '伤了我，休想全身而退！',
}

enyuan:addEffect(fk.AfterCardsMove, {
  mute = true,
  anim_type = "masochism",
  can_trigger = function(skill, event, target, player, data)
    if player:hasSkill(enyuan.name) then
    for _, move in ipairs(data) do
      if move.from and move.from ~= player.id and move.to == player.id and move.toArea == Card.PlayerHand and
      #move.moveInfo > 1 and not player.room:getPlayerById(move.from).dead then
      return true
      end
    end
    end
  end,
  on_trigger = function(skill, event, target, player, data)
    for _, move in ipairs(data) do
    if player.dead or not player:hasSkill(enyuan.name) then return end
    if move.from and move.from ~= player.id and move.to == player.id and move.toArea == Card.PlayerHand and #move.moveInfo > 1 and
      #move.moveInfo > 1 and not player.room:getPlayerById(move.from).dead then
      skill:doCost(event, target, player, move.from)
    end
    end
  end,
  on_cost = function(skill, event, target, player, data)
    local prompt = "#enyuan1-invoke::" .. data
    return player.room:askToSkillInvoke(player, {skill_name = enyuan.name, prompt = prompt})
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(enyuan.name, 1)
    room:notifySkillInvoked(player, enyuan.name, "support")
    room:doIndicate(player.id, {data})
    room:getPlayerById(data):drawCards(1, enyuan.name)
  end,
})

enyuan:addEffect(fk.Damaged, {
  mute = true,
  anim_type = "masochism",
  can_trigger = function(skill, event, target, player, data)
    return target == player and data.from and data.from ~= player.id and not data.from.dead
  end,
  on_trigger = function(skill, event, target, player, data)
    skill:doCost(event, target, player, data.from)
  end,
  on_cost = function(skill, event, target, player, data)
    local prompt = "#enyuan2-invoke::" .. data.from.id
    return player.room:askToSkillInvoke(player, {skill_name = enyuan.name, prompt = prompt})
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(enyuan.name, 2)
    room:notifySkillInvoked(player, enyuan.name)
    room:doIndicate(player.id, {data.from.id})
    if data.from:isKongcheng() then
    room:loseHp(data.from, 1, enyuan.name)
    else
    local card = room:askToCards(data.from, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      pattern = ".|.|.|hand|.|.",
      prompt = "#enyuan-give:" .. player.id,
      cancelable = true,
    })
    if #card > 0 then
      room:obtainCard(player, Fk:getCardById(card[1]), true, fk.ReasonGive, data.from.id)
    else
      room:loseHp(data.from, 1, enyuan.name)
    end
    end
  end,
})

return enyuan
```