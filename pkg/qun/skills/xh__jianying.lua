-- SPDX-License-Identifier: GPL-3.0-or-later
-- 沮授 - 渐营技能
-- 当你使用牌时，若此牌与你使用的上一张牌点数或花色相同，你可以摸一张牌。

local jianying = fk.CreateSkill {
  name = "xh__jianying",
}

Fk:loadTranslationTable {
  ["xh__jianying"] = "渐营",
  [":xh__jianying"] = "当你使用牌时，若此牌与你使用的上一张牌点数或花色相同，你可以摸一张牌。",

  ["#xh__jianying-invoke"] = "渐营：是否摸一张牌？",
  ["@@xh__jianying_last"] = "渐营上一张牌",

  ["$xh__jianying1"] = "渐营之计，步步为营！",
  ["$xh__jianying2"] = "河北谋士，智计百出！",
}

jianying:addEffect(fk.CardUsing, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(jianying.name) then return false end
    if not data.card then return false end
    
    local last = player:getMark("@@jianying_last")
    if not last or type(last) ~= "table" then return false end
    
    local same_number = data.card.number == last.number
    local same_suit = data.card.suit == last.suit
    
    return same_number or same_suit
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = jianying.name,
      prompt = "#xh__jianying-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, jianying.name)
  end,
})

-- 记录上一张使用的牌
jianying:addEffect(fk.CardUsing, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@jianying_last", {
      number = data.card.number,
      suit = data.card.suit,
    })
  end,
})

return jianying
