-- SPDX-License-Identifier: GPL-3.0-or-later
-- 颜良文丑 - 双雄技能
-- 摸牌阶段结束时，你可以弃置一张牌，然后本回合你可以将与之颜色不同的一张牌当【决斗】使用。
-- 结束阶段，你获得本回合对你造成伤害的牌。

local shuangxiong = fk.CreateSkill {
  name = "xh__shuangxiong",
}

Fk:loadTranslationTable {
  ["xh__shuangxiong"] = "双雄",
  [":xh__shuangxiong"] = "摸牌阶段结束时，你可以弃置一张牌，然后本回合你可以将与之颜色不同的一张牌当【决斗】使用。"..
    "结束阶段，你获得本回合对你造成伤害的牌。",

  ["#xh__shuangxiong-discard"] = "双雄：弃置一张牌",
  ["@@xh__shuangxiong_color"] = "双雄",
  ["@@xh__shuangxiong_damage"] = "双雄伤害牌",

  ["$xh__shuangxiong1"] = "双雄并立，天下无双！",
  ["$xh__shuangxiong2"] = "颜良文丑，勇冠三军！",
}

-- 摸牌阶段结束时弃牌
shuangxiong:addEffect(fk.EventPhaseEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shuangxiong.name) and
      player.phase == Player.Draw and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = shuangxiong.name,
      pattern = ".",
      prompt = "#xh__shuangxiong-discard",
      cancelable = true,
    })
    
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card_id = event:getCostData(self).cards[1]
    local card = Fk:getCardById(card_id)
    
    room:throwCard(card_id, shuangxiong.name, player, player)
    
    -- 记录颜色
    room:setPlayerMark(player, "@@shuangxiong_color", card.color)
  end,
})

-- 将不同颜色的牌当决斗使用
shuangxiong:addEffect("viewas", {
  mute = true,
  pattern = "duel",
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    
    local color = player:getMark("@@shuangxiong_color")
    if color == 0 then return false end
    
    return Fk:getCardById(to_select).color ~= color
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    
    local card = Fk:cloneCard("duel")
    card.skillName = shuangxiong.name
    card:addSubcard(cards[1])
    return card
  end,
  enabled_at_play = function(self, player)
    return player:getMark("@@shuangxiong_color") ~= 0
  end,
})

-- 结束阶段获得造成伤害的牌
shuangxiong:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shuangxiong.name) and
      player.phase == Player.Finish and
      player:getMark("@@shuangxiong_damage") ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player:getMark("@@shuangxiong_damage")
    
    if type(cards) == "table" then
      for _, id in ipairs(cards) do
        if table.contains(room.discard_pile, id) then
          room:moveCardTo(id, Player.Hand, player, fk.ReasonPrey, shuangxiong.name)
        end
      end
    end
    
    room:setPlayerMark(player, "@@shuangxiong_damage", 0)
  end,
})

-- 记录造成伤害的牌
shuangxiong:addEffect(fk.Damage, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not data.card then return false end
    return data.to == player and player:hasSkill(shuangxiong.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player:getMark("@@shuangxiong_damage") or {}
    
    if type(cards) ~= "table" then cards = {} end
    
    table.insert(cards, data.card.id)
    room:setPlayerMark(player, "@@shuangxiong_damage", cards)
  end,
})

-- 回合结束清除标记
shuangxiong:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@shuangxiong_color") ~= 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@shuangxiong_color", 0)
  end,
})

return shuangxiong
