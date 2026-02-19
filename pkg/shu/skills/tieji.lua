-- SPDX-License-Identifier: GPL-3.0-or-later
-- 马超 - 铁骑技能
-- 当你使用【杀】指定目标后，你可以令其本回合非锁定技失效，
-- 然后你判定，除非其弃置一张与判定结果花色相同的牌，否则其不能抵消此【杀】。

local tieji = fk.CreateSkill {
  name = "tieji",
}

Fk:loadTranslationTable {
  ["tieji"] = "铁骑",
  [":tieji"] = "当你使用【杀】指定目标后，你可以令其本回合非锁定技失效，"..
    "然后你判定，除非其弃置一张与判定结果花色相同的牌，否则其不能抵消此【杀】。",

  ["#tieji-invoke"] = "铁骑：是否令目标非锁定技失效并进行判定？",
  ["#tieji-discard"] = "铁骑：弃置一张%arg花色的牌，否则不能抵消此杀",

  ["$tieji1"] = "铁骑突阵，势不可挡！",
  ["$tieji2"] = "西凉铁骑，天下无双！",
}

tieji:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tieji.name) and
      data.card and data.card.trueName == "slash"
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = tieji.name,
      prompt = "#tieji-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    
    -- 令其非锁定技失效
    room:addPlayerMark(to, "@@tieji_disable", 1)
    
    -- 判定
    local judge = room:judge{
      who = player,
      reason = tieji.name,
    }
    
    -- 记录判定花色
    local suit = judge.card.suit
    room:setPlayerMark(to, "@@tieji_suit", suit)
  end,
})

-- 不能抵消杀
tieji:addEffect(fk.CardEffecting, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if not data.card or data.card.trueName ~= "slash" then return false end
    local suit = player:getMark("@@tieji_suit")
    if suit == 0 then return false end
    
    -- 检查是否弃置了对应花色的牌
    local cards = player:getCardIds("he")
    local has_suit = table.find(cards, function(id)
      return Fk:getCardById(id).suit == suit
    end)
    
    if not has_suit then return true end
    
    -- 询问是否弃牌
    local room = player.room
    local suit_cards = table.filter(cards, function(id)
      return Fk:getCardById(id).suit == suit
    end)
    
    local id = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = tieji.name,
      pattern = tostring(Exppattern{ id = suit_cards }),
      prompt = "#tieji-discard:::" .. suit,
      cancelable = true,
    })
    
    if #id > 0 then
      room:throwCard(id, tieji.name, player, player)
      room:setPlayerMark(player, "@@tieji_suit", 0)
      return false
    end
    
    return true
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.nullified = true
  end,
})

-- 回合结束清除标记
tieji:addEffect(fk.TurnEnd, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@tieji_disable") > 0 or player:getMark("@@tieji_suit") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@tieji_disable", 0)
    room:setPlayerMark(player, "@@tieji_suit", 0)
  end,
})

return tieji
