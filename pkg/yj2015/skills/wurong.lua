```lua
local wurong = fk.CreateSkill {
  name = "wurong"
}

Fk:loadTranslationTable{
  ['wurong'] = '怃戎',
  ['#wurong-show'] = '怃戎：选择一张展示的手牌',
  [':wurong'] = '出牌阶段限一次，你可以和一名其他角色同时展示一张手牌：若你展示的是【杀】且该角色不是【闪】，你弃置此【杀】，然后对其造成1点伤害；若你展示的不是【杀】且该角色是【闪】，你弃置此牌，然后获得其一张牌。',
  ['$wurong1'] = '兵不血刃，亦可先声夺人。',
  ['$wurong2'] = '从则安之，犯则诛之。',
}

wurong:addEffect('active', {
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(wurong.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, player, to_select, selected)
    return false
  end,
  target_filter = function(self, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local fromCard = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      pattern = ".",
      prompt = "#wurong-show"
    })[1]
    local toCard = room:askToCards(target, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      pattern = ".",
      prompt = "#wurong-show"
    })[1]
    player:showCards(fromCard)
    target:showCards(toCard)
    if Fk:getCardById(fromCard).trueName == "slash" and Fk:getCardById(toCard).name ~= "jink" then
      room:throwCard({fromCard}, wurong.name, player, player)
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = wurong.name,
      }
    end
    if Fk:getCardById(fromCard).trueName ~= "slash" and Fk:getCardById(toCard).name == "jink" then
      room:throwCard({fromCard}, wurong.name, player, player)
      local id = room:askToChooseCard(player, {
        target = target,
        flag = "he",
        skill_name = wurong.name
      })
      room:obtainCard(player, id, false)
    end
  end,
})

return wurong
```