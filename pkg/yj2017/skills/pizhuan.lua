local pizhuan = fk.CreateSkill {
  name = "pizhuan"
}

Fk:loadTranslationTable{
  ['pizhuan'] = '辟撰',
  ['caiyong_book'] = '书',
  [':pizhuan'] = '当你使用♠牌时，或你成为其他角色使用♠牌的目标后，你可以将牌堆顶的一张牌置于武将牌上，称为“书”；你至多拥有四张“书”，你的手牌上限+X（X为“书”的数量）。',
  ['$pizhuan1'] = '无墨不成书，无识不成才。',
  ['$pizhuan2'] = '笔可抒情，亦可诛心。',
}

pizhuan:addEffect(fk.CardUsing, {
  anim_type = "special",
  derived_piles = "caiyong_book",
  can_trigger = function(skill, event, target, player, data)
    if target == player and player:hasSkill(pizhuan) and data.card.suit == Card.Spade and
      #player:getPile("caiyong_book") < 4 + player:getMark("pizhuan_extra") then
      return true
    end
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    if room:askToChoice(player, {
      choices = {"yes", "no"},
      skill_name = pizhuan.name,
      prompt = "是否将牌堆顶的一张牌置于武将牌上？"
    }) == "yes" then
      player:addToPile("caiyong_book", room:getNCards(1), true, pizhuan.name)
    end
  end,
})

pizhuan:addEffect(fk.TargetConfirmed, {
  anim_type = "special",
  derived_piles = "caiyong_book",
  can_trigger = function(skill, event, target, player, data)
    if target == player and player:hasSkill(pizhuan) and data.card.suit == Card.Spade and
      #player:getPile("caiyong_book") < 4 + player:getMark("pizhuan_extra") then
      return data.from ~= player.id
    end
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    if room:askToChoice(player, {
      choices = {"yes", "no"},
      skill_name = pizhuan.name,
      prompt = "是否将牌堆顶的一张牌置于武将牌上？"
    }) == "yes" then
      player:addToPile("caiyong_book", room:getNCards(1), true, pizhuan.name)
    end
  end,
})

pizhuan:addEffect('maxcards', {
  correct_func = function(skill, player)
  if player:hasSkill(pizhuan) then
    return #player:getPile("caiyong_book")
  end
  end,
})

return pizhuan