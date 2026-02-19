-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张郃 - 周旋技能
-- 弃牌阶段开始时，你可以将任意张手牌扣置于你的武将牌上，称为"旋"（至多五张），
-- 直到你下个出牌阶段结束。当你使用牌时你移去一张"旋"并摸一张牌。

local zhouxuan = fk.CreateSkill {
  name = "xh__zhouxuan",
}

Fk:loadTranslationTable {
  ["xh__zhouxuan"] = "周旋",
  [":xh__zhouxuan"] = "弃牌阶段开始时，你可以将任意张手牌扣置于你的武将牌上，称为\"旋\"（至多五张），"..
    "直到你下个出牌阶段结束。当你使用牌时你移去一张\"旋\"并摸一张牌。",

  ["#xh__zhouxuan-place"] = "周旋：选择要置为旋的手牌",
  ["@@xh__zhouxuan_xuan"] = "旋",

  ["$xh__zhouxuan1"] = "周旋之计，智取天下！",
  ["$xh__zhouxuan2"] = "张郃周旋，天下无双！",
}

zhouxuan:addEffect(fk.EventPhaseStart, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(xh__zhouxuan.name) then return false end
    if player.phase ~= Player.Discard then return false end
    return not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = math.min(5, player:getHandcardNum()),
      include_equip = false,
      skill_name = xh__zhouxuan.name,
      pattern = ".",
      prompt = "#zhouxuan-place",
      cancelable = true,
    })
    
    if #cards > 0 then
      event:setCostData(self, {cards = cards})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = event:getCostData(self).cards
    
    -- 置为旋
    local xuan = player:getMark("@@zhouxuan_xuan") or {}
    if type(xuan) ~= "table" then xuan = {} end
    
    for _, id in ipairs(cards) do
      table.insert(xuan, id)
      room:moveCardTo(id, Card.Processing, player, fk.ReasonPut, xh__zhouxuan.name)
    end
    
    room:setPlayerMark(player, "@@zhouxuan_xuan", xuan)
  end,
})

-- 使用牌时移去旋并摸牌
zhouxuan:addEffect(fk.CardUsing, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(xh__zhouxuan.name) then return false end
    
    local xuan = player:getMark("@@zhouxuan_xuan")
    return xuan and type(xuan) == "table" and #xuan > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local xuan = player:getMark("@@zhouxuan_xuan")
    
    if #xuan > 0 then
      local id = table.remove(xuan, 1)
      room:moveCardTo(id, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, xh__zhouxuan.name)
      room:setPlayerMark(player, "@@zhouxuan_xuan", xuan)
      
      player:drawCards(1, xh__zhouxuan.name)
    end
  end,
})

return zhouxuan
