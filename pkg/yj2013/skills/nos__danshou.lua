local nos__danshou = fk.CreateSkill {
  name = "nos__danshou"
}

Fk:loadTranslationTable{
  ['nos__dans__houshou'] = '胆守',
  ['danshou'] = '胆守',
  [':nos__danshou'] = '每当你造成一次伤害后，你可以摸一张牌，若如此做，终止一切结算，当前回合结束。',
  ['$nos__danshou1'] = '到此为止了！',
  ['$nos__danshou2'] = '以胆为守，扼敌咽喉！',
}

nos__danshou:addEffect(fk.Damage, {
  on_use = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, { skill_name = "danshou" }) then
      player:broadcastSkillInvoke("danshou")
      room:notifySkillInvoked(player, skill.name)
      player:drawCards(1, skill.name)
      room.logic:breakTurn()
    end
  end,
})

return nos__danshou