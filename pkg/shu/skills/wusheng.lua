-- SPDX-License-Identifier: GPL-3.0-or-later
-- 关羽 - 武圣技能
-- 你可以将一张红色牌当【杀】使用或打出。你使用♢【杀】无距离限制。

local wusheng = fk.CreateSkill {
  name = "wusheng",
}

Fk:loadTranslationTable {
  ["wusheng"] = "武圣",
  [":wusheng"] = "你可以将一张红色牌当【杀】使用或打出。你使用♢【杀】无距离限制。",

  ["#wusheng-use"] = "武圣：将一张红色牌当【杀】使用",

  ["$wusheng1"] = "观尔乃插标卖首！",
  ["$wusheng2"] = "关羽在此，谁敢来犯！",
}

wusheng:addEffect("viewas", {
  mute = true,
  pattern = "slash",
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    local card = Fk:getCardById(to_select)
    return card.color == Card.Red
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    local card = Fk:cloneCard("slash")
    card.skillName = wusheng.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function(self, player)
    return player:canUse(Fk:cloneCard("slash"))
  end,
  enabled_at_response = function(self, player)
    return true
  end,
})

-- ♢【杀】无距离限制
wusheng:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    local card = data.card
    if not card then return false end
    if card.trueName ~= "slash" then return false end

    -- 检查是否为♢牌
    local subcards = card.subcards
    if #subcards == 0 then return false end

    local subcard = Fk:getCardById(subcards[1])
    return subcard.suit == Card.Diamond
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.wusheng_no_distance = true
  end,
})

wusheng:addEffect(fk.TargetSpecifying, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    local card = data.card
    if not card then return false end
    if card.trueName ~= "slash" then return false end

    local extra_data = data.extra_data or {}
    return extra_data.wusheng_no_distance
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.bypass_distances = true
  end,
})

return wusheng
