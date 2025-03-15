local nos__qianxi = fk.CreateSkill {
  name = "nos__qianxi"
}

Fk:loadTranslationTable{
  ['nos__qianxi'] = '潜袭',
  [':nos__qianxi'] = '每当你使用【杀】对距离为1的目标角色造成伤害时，你可以进行一次判定，若判定结果不为<font color=>♥</font>，你防止此伤害，改为令其减1点体力上限。',
  ['$nos__qianxi1'] = '伤其十指，不如断其一指！',
  ['$nos__qianxi2'] = '斩草除根，除恶务尽！',
}

nos__qianxi:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and player:distanceTo(data.to) == 1 and
         data.card and data.card.trueName == "slash" and player.room.logic:damageByCardEffect()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = skill.name,
      pattern = ".|.|^heart",
    }
    room:judge(judge)
    if judge.card.suit ~= Card.Heart then
      if not data.to.dead then
        room:changeMaxHp(data.to, -1)
      end
      return true
    end
  end,
})

return nos__qianxi