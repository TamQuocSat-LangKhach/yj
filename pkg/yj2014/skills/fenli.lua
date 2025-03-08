local fenli = fk.CreateSkill {
  name = "fenli"
}

Fk:loadTranslationTable{
  ['fenli'] = '奋励',
  ['#fenli-invoke'] = '奋励：你可以跳过%arg',
  [':fenli'] = '若你的手牌数为全场最多，你可以跳过摸牌阶段；若你的体力值为全场最多，你可以跳过出牌阶段；若你的装备区里有牌且数量为全场最多，你可以跳过弃牌阶段。',
  ['$fenli1'] = '以逸待劳，坐收渔利。',
  ['$fenli2'] = '以主制客，占尽优势。',
}

fenli:addEffect(fk.EventPhaseChanging, {
  can_trigger = function(skill, event, target, player, data)
    if target ~= player or not player:hasSkill(fenli.name) then return false end
    if data.to == Player.Draw then
      return table.every(player.room:getOtherPlayers(player), function (p)
        return p:getHandcardNum() <= player:getHandcardNum()
      end)
    elseif data.to == Player.Play then
      return table.every(player.room:getOtherPlayers(player), function (p) 
        return p.hp <= player.hp 
      end)
    elseif data.to == Player.Discard and #player.player_cards[Player.Equip] > 0 then
      return table.every(player.room:getOtherPlayers(player), function (p)
        return #p.player_cards[Player.Equip] <= #player.player_cards[Player.Equip]
      end)
    end
  end,
  on_cost = function(skill, event, target, player, data)
    local phases = {"phase_draw", "phase_play", "phase_discard"}
    return player.room:askToSkillInvoke(player, {
      skill_name = fenli.name,
      prompt = "#fenli-invoke:::"..phases[data.to - 3],
    })
  end,
  on_use = function(skill, event, target, player, data)
    player:skip(data.to)
    return true
  end,
})

return fenli