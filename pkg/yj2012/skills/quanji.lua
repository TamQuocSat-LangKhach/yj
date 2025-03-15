local quanji = fk.CreateSkill {
  name = "quanji"
}

Fk:loadTranslationTable{
  ['quanji'] = '权计',
  ['zhonghui_quan'] = '权',
  ['#quanji-card'] = '权计：将一张手牌置为“权”',
  [':quanji'] = '每当你受到1点伤害后，你可以摸一张牌，然后将一张手牌置于武将牌上，称为“权”；每有一张“权”，你的手牌上限便+1。',
  ['$quanji1'] = '这仇，我记下了。',
  ['$quanji2'] = '先让你得意几天。',
}

quanji:addEffect(fk.Damaged, {
  anim_type = "masochism",
  derived_piles = {"zhonghui_quan"},
  on_trigger = function(self, event, target, player, data)
    skill.cancel_cost = false
    for i = 1, data.damage do
      if skill.cancel_cost or player.dead then break end
      skill:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {skill_name = quanji.name, prompt = data}) then
      return true
    end
    skill.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, quanji.name)
    if player:isKongcheng() then return end
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = quanji.name,
      cancelable = false,
      pattern = ".",
      prompt = "#quanji-card"
    })
    player:addToPile("zhonghui_quan", card[1], true, quanji.name)
  end,
})

local quanji_maxcards = fk.CreateMaxCardsSkill{
  name = "#quanji_maxcards",
  correct_func = function(self, player)
    if player:hasSkill(quanji) then
      return #player:getPile("zhonghui_quan")
    else
      return 0
    end
  end,
}

return quanji