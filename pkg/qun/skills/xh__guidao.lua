-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张角 - 鬼道技能
-- 当一张判定牌生效前，你可以用一张黑色牌替换之。

local guidao = fk.CreateSkill {
  name = "xh__guidao",
}

Fk:loadTranslationTable {
  ["xh__guidao"] = "鬼道",
  [":xh__guidao"] = "当一张判定牌生效前，你可以用一张黑色牌替换之。",

  ["#xh__guidao-replace"] = "鬼道：是否用一张黑色牌替换判定牌？",

  ["$xh__guidao1"] = "鬼道无常，变化莫测！",
  ["$xh__guidao2"] = "天命在我，谁能违逆！",
}

guidao:addEffect(fk.AskForRetrial, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(guidao.name) then return false end
    
    -- 检查是否有黑色牌
    local cards = player:getCardIds("he")
    return table.find(cards, function(id)
      return Fk:getCardById(id).color == Card.Black
    end)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = guidao.name,
      prompt = "#xh__guidao-replace",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    local black_cards = table.filter(player:getCardIds("he"), function(id)
      return Fk:getCardById(id).color == Card.Black
    end)
    
    local card_id = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = guidao.name,
      pattern = tostring(Exppattern{ id = black_cards }),
      prompt = "选择一张黑色牌替换判定牌",
      cancelable = false,
    })
    
    room:retrial(card_id[1], player, data, guidao.name)
  end,
})

return guidao
