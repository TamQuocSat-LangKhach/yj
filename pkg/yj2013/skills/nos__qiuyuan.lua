local nos__qiuyuan = fk.CreateSkill {
  name = "nos__qiuyuan"
}

Fk:loadTranslationTable{
  ['nos__qiuyuan'] = '求援',
  ['#nos__qiuyuan-choose'] = '求援：令另一名其他角色交给你一张手牌',
  ['#nos__qiuyuan-give'] = '求援：你需交给 %dest 一张手牌',
  [':nos__qiuyuan'] = '当你成为【杀】的目标时，你可以令一名有手牌的其他角色交给你一张手牌。若此牌不为【闪】，该角色也成为此【杀】的目标（该角色不得是此【杀】的使用者）。',
  ['$nos__qiuyuan1'] = '陛下，我该怎么办？',
  ['$nos__qiuyuan2'] = '曹贼暴虐，谁可诛之！'
}

nos__qiuyuan:addEffect(fk.TargetConfirming, {
  anim_type = "defensive",
  can_trigger = function(skill, event, target, player, data)
    if not (target == player and player:hasSkill(nos__qiuyuan) and data.card.trueName == "slash") then return end
    local targets = table.map(table.filter(player.room:getOtherPlayers(player), function(p)
    return p.id ~= data.from and not p:isKongcheng() end), Util.IdMapper)
    return #targets > 0
  end,
  on_cost = function(skill, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
    return p.id ~= data.from and not p:isKongcheng() end), Util.IdMapper)
    local to = room:askToChoosePlayers(player, {
    targets = Fk:findPlayersByIds(targets),
    min_num = 1,
    max_num = 1,
    prompt = "#nos__qiuyuan-choose",
    skill_name = nos__qiuyuan.name
    })
    if #to > 0 then
    event:setCostData(skill, to[1].id)
    return true
    end
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(event:getCostData(skill))
    room:doIndicate(player.id, {to})
    local card = room:askToCards(to, {
    min_num = 1,
    max_num = 1,
    pattern = ".|.|.|hand",
    prompt = "#nos__qiuyuan-give::" .. player.id,
    skill_name = nos__qiuyuan.name
    })
    if #card > 0 then
    local cardObj = Fk:getCardById(card[1])
    room:obtainCard(player.id, cardObj, true, fk.ReasonGive, to.id)
    if cardObj.name ~= "jink" then
      TargetGroup:pushTargets(data.targetGroup, to.id)
    end
    end
  end,
})

return nos__qiuyuan