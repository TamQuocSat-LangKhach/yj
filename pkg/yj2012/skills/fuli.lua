```lua
local fuli = fk.CreateSkill {
  name = "fuli"
}

Fk:loadTranslationTable{
  ['fuli'] = '伏枥',
  [':fuli'] = '限定技，当你处于濒死状态时，你可以将体力值回复至X点（X为现存势力数），然后将你的武将牌翻面。',
  ['$fuli1'] = '今天是个拼命的好日子，哈哈哈哈！',
  ['$fuli2'] = '有老夫在，蜀汉就不会倒下！',
}

fuli:addEffect(fk.AskForPeaches, {
  anim_type = "defensive",
  frequency = Skill.Limited,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and player.dying and player:usedSkillTimes(skill.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local kingdoms = {}
    for _, p in ipairs(room:getAlivePlayers()) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    room:recover({
      who = player,
      num = math.min(#kingdoms, player.maxHp) - player.hp,
      recoverBy = player,
      skillName = skill.name
    })
    player:turnOver()
  end,
})

return fuli
```