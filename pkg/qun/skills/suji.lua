-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张燕 - 肃疾技能
-- 已受伤角色的出牌阶段开始时，你可以将一张黑色牌当【杀】使用，若其受到此【杀】伤害，你获得其一张牌。

local suji = fk.CreateSkill {
  name = "suji",
}

Fk:loadTranslationTable {
  ["suji"] = "肃疾",
  [":suji"] = "已受伤角色的出牌阶段开始时，你可以将一张黑色牌当【杀】使用，若其受到此【杀】伤害，你获得其一张牌。",

  ["#suji-invoke"] = "肃疾：是否将一张黑色牌当杀使用？",
  ["@@suji_damage"] = "肃疾伤害",

  ["$suji1"] = "肃疾之威，势不可挡！",
  ["$suji2"] = "黑山军威，天下无双！",
}

suji:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(suji.name) then return false end
    if target == player then return false end
    if target.phase ~= Player.Play then return false end
    if not target:isWounded() then return false end
    
    -- 检查是否有黑色牌
    local black_cards = table.filter(player:getCardIds("he"), function(id)
      return Fk:getCardById(id).color == Card.Black
    end)
    
    return #black_cards > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    
    local black_cards = table.filter(player:getCardIds("he"), function(id)
      return Fk:getCardById(id).color == Card.Black
    end)
    
    local card_id = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = suji.name,
      pattern = tostring(Exppattern{ id = black_cards }),
      prompt = "#suji-invoke",
      cancelable = true,
    })
    
    if #card_id > 0 then
      event:setCostData(self, {cards = card_id, to = target})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card_id = event:getCostData(self).cards[1]
    
    room:setPlayerMark(player, "@@suji_damage", 0)
    
    local slash = Fk:cloneCard("slash")
    slash.skillName = suji.name
    slash:addSubcard(card_id)
    
    room:useCard{
      from = player.id,
      tos = {target.id},
      card = slash,
      extra_data = { suji = true },
    }
    
    -- 如果造成伤害，获得一张牌
    if player:getMark("@@suji_damage") > 0 and not target:isNude() then
      local id = room:askToChooseCard(player, {
        target = target,
        flag = "he",
        skill_name = suji.name,
      })
      room:moveCardTo(id, Player.Hand, player, fk.ReasonPrey, suji.name)
    end
    
    room:setPlayerMark(player, "@@suji_damage", 0)
  end,
})

-- 记录是否造成伤害
suji:addEffect(fk.Damage, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and data.card and data.card.extra_data and data.card.extra_data.suji
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@@suji_damage", 1)
  end,
})

return suji
