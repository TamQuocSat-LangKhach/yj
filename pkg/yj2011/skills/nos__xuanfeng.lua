local nos__xuanfeng = fk.CreateSkill {
  name = "nos__xuanfeng"
}

Fk:loadTranslationTable{
  ['nos__xuanfeng'] = '旋风',
  ['#nos__xuanfeng-choose'] = '旋风：你可以视为使用一张【杀】，或对距离1的一名其他角色造成1点伤害',
  ['nos__xuanfeng_slash'] = '视为对其使用【杀】',
  ['nos__xuanfeng_damage'] = '对其造成1点伤害',
  [':nos__xuanfeng'] = '当你失去装备区内的牌后，你可以选择一项：1.视为使用一张【杀】（无距离次数限制）；2.对距离1的一名其他角色造成1点伤害。',
  ['$nos__xuanfeng1'] = '伤敌于千里之外！',
  ['$nos__xuanfeng2'] = '索命于须臾之间！',
}

nos__xuanfeng:addEffect(fk.AfterCardsMove, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(nos__xuanfeng.name) then return end
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip then
            return true
          end
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
      return (not player:isProhibited(p, Fk:cloneCard("slash")) or player:distanceTo(p) == 1) end), Util.IdMapper)
    if #targets == 0 then return end
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#nos__xuanfeng-choose",
      skill_name = nos__xuanfeng.name,
      cancelable = true
    })
    if #to > 0 then
      event:setCostData(self, to[1].id)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(event:getCostData(self))
    local choices = {}
    if not player:isProhibited(to, Fk:cloneCard("slash")) then
      table.insert(choices, "nos__xuanfeng_slash")
    end
    if player:distanceTo(to) == 1 then
      table.insert(choices, "nos__xuanfeng_damage")
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = nos__xuanfeng.name
    })
    if choice == "nos__xuanfeng_slash" then
      room:useVirtualCard("slash", nil, player, to, nos__xuanfeng.name, true)
    else
      room:damage{
        from = player,
        to = to,
        damage = 1,
        skillName = nos__xuanfeng.name,
      }
    end
  end,
})

return nos__xuanfeng