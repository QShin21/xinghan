-- SPDX-License-Identifier: GPL-3.0-or-later
-- 贾诩 - 帷幕技能
-- 锁定技，当你成为黑色锦囊牌的目标时，取消之；
-- 当你于回合内受到伤害时，你摸2X张牌，然后防止此伤害（X为此伤害值）。

local weimu = fk.CreateSkill {
  name = "weimu",
}

Fk:loadTranslationTable {
  ["weimu"] = "帷幕",
  [":weimu"] = "锁定技，当你成为黑色锦囊牌的目标时，取消之；"..
    "当你于回合内受到伤害时，你摸2X张牌，然后防止此伤害（X为此伤害值）。",

  ["$weimu1"] = "此计伤不到我！",
  ["$weimu2"] = "我就静静地看着你们。",
}

-- 黑色锦囊牌无效
weimu:addEffect(fk.TargetConfirming, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(weimu.name) then return false end

    local card = data.card
    if not card then return false end

    return card.color == Card.Black and card.type == Card.TypeTrick
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {data.from})

    -- 取消目标
    local tos = data:preGetTargetPlayers()
    table.removeOne(tos, player)
    data:setTargetPlayers(tos)
  end,
})

-- 回合内受伤摸牌并防止伤害
weimu:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(weimu.name) and
      player.room.current == player and data.damage > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local x = data.damage

    -- 摸2X张牌
    player:drawCards(2 * x, weimu.name)

    -- 防止伤害
    data:preventDamage()
  end,
})

return weimu
