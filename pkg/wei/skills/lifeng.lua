-- SPDX-License-Identifier: GPL-3.0-or-later
-- 曹仁 - 砺锋技能
-- 你的回合外，你可以将一张本回合所有角色均未使用过的颜色的手牌当【无懈可击】使用。

local lifeng = fk.CreateSkill {
  name = "xh__lifeng",
}

Fk:loadTranslationTable {
  ["xh__lifeng"] = "砺锋",
  [":xh__lifeng"] = "你的回合外，你可以将一张本回合所有角色均未使用过的颜色的手牌当【无懈可击】使用。",

  ["#xh__lifeng-use"] = "砺锋：你可以将一张未使用过颜色的手牌当【无懈可击】使用",
  ["@@xh__lifeng_used_red"] = "砺锋红",
  ["@@xh__lifeng_used_black"] = "砺锋黑",

  ["$xh__lifeng1"] = "锋芒毕露，锐不可当！",
  ["$xh__lifeng2"] = "砺剑待发，一击必中！",
}

-- 记录本回合使用过的牌的颜色
lifeng:addEffect(fk.CardUsing, {
  can_trigger = function(self, event, target, player, data)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = data.card
    if not card then return end

    -- 记录颜色
    if card.color == Card.Red then
      room:setPlayerMark(room.current, "@@lifeng_used_red", 1)
    elseif card.color == Card.Black then
      room:setPlayerMark(room.current, "@@lifeng_used_black", 1)
    end
  end,
})

-- 回合开始时清除标记
lifeng:addEffect(fk.TurnStart, {
  can_trigger = function(self, event, target, player, data)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@lifeng_used_red", 0)
    room:setPlayerMark(player, "@@lifeng_used_black", 0)
  end,
})

-- 作为无懈可击使用
lifeng:addEffect("viewas", {
  mute = true,
  pattern = "nullification",
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    local card = Fk:getCardById(to_select)
    local room = player.room
    local current = room.current

    -- 检查颜色是否未被使用过
    if card.color == Card.Red then
      return current:getMark("@@lifeng_used_red") == 0
    elseif card.color == Card.Black then
      return current:getMark("@@lifeng_used_black") == 0
    end
    return false
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    local card = Fk:cloneCard("nullification")
    card.skillName = xh__lifeng.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function(self, player)
    return false
  end,
  enabled_at_response = function(self, player)
    return player.phase == Player.NotActive and not player:isKongcheng()
  end,
})

return lifeng
