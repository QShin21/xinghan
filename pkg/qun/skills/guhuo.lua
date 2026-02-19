-- SPDX-License-Identifier: GPL-3.0-or-later
-- 于吉 - 蛊惑技能
-- 每名角色的回合限一次，你可以扣置一张手牌当任意一张基本牌或普通锦囊牌使用或打出；
-- 此时，一旦有其他角色质疑则翻开此牌：若为假则此牌作废，若为真则质疑角色获得技能"缠怨"。

local guhuo = fk.CreateSkill {
  name = "guhuo",
}

Fk:loadTranslationTable {
  ["guhuo"] = "蛊惑",
  [":guhuo"] = "每名角色的回合限一次，你可以扣置一张手牌当任意一张基本牌或普通锦囊牌使用或打出；"..
    "此时，一旦有其他角色质疑则翻开此牌：若为假则此牌作废，若为真则质疑角色获得技能\"缠怨\"。",

  ["#guhuo-use"] = "蛊惑：扣置一张手牌当任意基本牌或普通锦囊牌使用",

  ["$guhuo1"] = "蛊惑人心，真假难辨！",
  ["$guhuo2"] = "信我者生，疑我者死！",
}

guhuo:addEffect("viewas", {
  mute = true,
  pattern = "basic,trick",
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    return table.contains(player:getCardIds("h"), to_select)
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return nil end
    
    -- 需要玩家选择要使用的牌
    return nil
  end,
  enabled_at_play = function(self, player)
    return player:getMark("@@guhuo_used") == 0 and not player:isKongcheng()
  end,
  enabled_at_response = function(self, player, response)
    return player:getMark("@@guhuo_used") == 0 and not player:isKongcheng()
  end,
})

-- 使用active技能来处理
guhuo:addEffect("active", {
  mute = true,
  prompt = "#guhuo-use",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:getMark("@@guhuo_used") == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, player, to_select, selected)
    if #selected > 0 then return false end
    return table.contains(player:getCardIds("h"), to_select)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local card_id = effect.cards[1]
    
    room:notifySkillInvoked(player, guhuo.name, "offensive")
    player:broadcastSkillInvoke(guhuo.name)
    
    -- 标记已使用
    room:setPlayerMark(player, "@@guhuo_used", 1)
    
    -- 扣置手牌
    room:moveCardTo(card_id, Card.Processing, player, fk.ReasonPut, guhuo.name)
    
    -- 让玩家选择要使用的牌名
    local card_names = {}
    for name, _ in pairs(Fk.packages["standard_cards"].cards) do
      local card = Fk.cards[name]
      if card and (card.type == Card.TypeBasic or card.type == Card.TypeTrick) then
        table.insert(card_names, name)
      end
    end
    
    local choice = room:askToChoice(player, {
      choices = card_names,
      skill_name = guhuo.name,
      prompt = "选择要当什么牌使用",
      detailed = true,
    })
    
    -- 创建虚拟牌
    local card = Fk:cloneCard(choice)
    card.skillName = guhuo.name
    card:addSubcard(card_id)
    
    -- 使用卡牌
    room:useCard{
      from = player.id,
      card = card,
    }
  end,
})

-- 回合结束清除标记
guhuo:addEffect(fk.TurnEnd, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@guhuo_used") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@guhuo_used", 0)
  end,
})

return guhuo
