-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张辽(群) - 资取技能
-- 限定技，当你对对手造成伤害时，你可以防止此伤害，
-- 令其展示所有手牌并交给你一张点数最大的牌然后你回复1点体力或摸两张牌。

local ziqu = fk.CreateSkill {
  name = "xh__ziqu",
  frequency = Skill.Limited,
}

Fk:loadTranslationTable {
  ["xh__ziqu"] = "资取",
  [":xh__ziqu"] = "限定技，当你对对手造成伤害时，你可以防止此伤害，"..
    "令其展示所有手牌并交给你一张点数最大的牌然后你回复1点体力或摸两张牌。",

  ["#xh__ziqu-invoke"] = "资取：是否防止伤害并获得牌？",
  ["ziqu_recover"] = "回复1点体力",
  ["ziqu_draw"] = "摸两张牌",

  ["$xh__ziqu1"] = "资取之计，借力打力！",
  ["$xh__ziqu2"] = "张辽资取，天下无双！",
}

ziqu:addEffect(fk.DamageCaused, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(ziqu.name) then return false end
    if player:usedSkillTimes(ziqu.name, Player.HistoryGame) > 0 then return false end
    if not data.to or data.to:isKongcheng() then return false end
    return true
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = ziqu.name,
      prompt = "#xh__ziqu-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    
    -- 防止伤害
    data:preventDamage()
    
    -- 展示所有手牌
    local handcards = to:getCardIds("h")
    room:showCards(to, handcards, ziqu.name)
    
    -- 找出点数最大的牌
    local max_number = 0
    for _, id in ipairs(handcards) do
      local num = Fk:getCardById(id).number
      if num > max_number then
        max_number = num
      end
    end
    
    local max_cards = table.filter(handcards, function(id)
      return Fk:getCardById(id).number == max_number
    end)
    
    -- 交给一张点数最大的牌
    if #max_cards > 0 then
      local id
      if #max_cards == 1 then
        id = max_cards[1]
      else
        id = room:askToCards(to, {
          min_num = 1,
          max_num = 1,
          include_equip = false,
          skill_name = ziqu.name,
          pattern = tostring(Exppattern{ id = max_cards }),
          prompt = "选择一张点数最大的牌交给" .. player.name,
          cancelable = false,
        })[1]
      end
      
      room:moveCardTo(id, Player.Hand, player, fk.ReasonGive, ziqu.name, nil, false, to.id)
    end
    
    -- 选择回复体力或摸牌
    local choice = room:askToChoice(player, {
      choices = {"ziqu_recover", "ziqu_draw"},
      skill_name = ziqu.name,
      prompt = "选择一项",
      detailed = false,
    })
    
    if choice == "ziqu_recover" then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = ziqu.name,
      }
    else
      player:drawCards(2, ziqu.name)
    end
  end,
})

return ziqu
