-- SPDX-License-Identifier: GPL-3.0-or-later
-- 徐庶 - 荐言技能
-- 出牌阶段每项限一次，你可以声明：一种牌的类别或一种牌的颜色，
-- 然后依次亮出牌堆顶的牌直到亮出符合你声明的牌并将此牌交给一名男性角色。

local jianyan = fk.CreateSkill {
  name = "xh__jianyan",
}

Fk:loadTranslationTable {
  ["xh__jianyan"] = "荐言",
  [":xh__jianyan"] = "出牌阶段每项限一次，你可以声明：一种牌的类别或一种牌的颜色，"..
    "然后依次亮出牌堆顶的牌直到亮出符合你声明的牌并将此牌交给一名男性角色。",

  ["#xh__jianyan-use"] = "荐言：选择声明类型或颜色",
  ["jianyan_basic"] = "声明基本牌",
  ["jianyan_trick"] = "声明锦囊牌",
  ["jianyan_equip"] = "声明装备牌",
  ["jianyan_red"] = "声明红色牌",
  ["jianyan_black"] = "声明黑色牌",

  ["$xh__jianyan1"] = "荐言献策，助君成事！",
  ["$xh__jianyan2"] = "良言相劝，望君采纳！",
}

jianyan:addEffect("active", {
  mute = true,
  prompt = "#jianyan-use",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    -- 检查是否还有未使用的选项
    local used = player:getMark("@@jianyan_used") or {}
    return #used < 5
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = effect.from

    room:notifySkillInvoked(player, xh__jianyan.name, "support")
    player:broadcastSkillInvoke(xh__jianyan.name)

    local used = player:getMark("@@jianyan_used") or {}
    local choices = {}
    
    if not table.contains(used, "basic") then table.insert(choices, "jianyan_basic") end
    if not table.contains(used, "trick") then table.insert(choices, "jianyan_trick") end
    if not table.contains(used, "equip") then table.insert(choices, "jianyan_equip") end
    if not table.contains(used, "red") then table.insert(choices, "jianyan_red") end
    if not table.contains(used, "black") then table.insert(choices, "jianyan_black") end
    
    if #choices == 0 then return end
    
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = xh__jianyan.name,
      prompt = "#jianyan-use",
      detailed = false,
    })
    
    -- 记录已使用
    local choice_key = choice:gsub("jianyan_", "")
    table.insert(used, choice_key)
    room:setPlayerMark(player, "@@jianyan_used", used)
    
    -- 翻牌找符合条件的牌
    local found_card = nil
    local revealed = {}
    
    while #room.draw_pile > 0 do
      local top_card = room.draw_pile[1]
      local card = Fk:getCardById(top_card)
      
      table.insert(revealed, top_card)
      room:showCards(player, {top_card}, xh__jianyan.name)
      
      local match = false
      if choice == "jianyan_basic" and card.type == Card.TypeBasic then match = true end
      if choice == "jianyan_trick" and card.type == Card.TypeTrick then match = true end
      if choice == "jianyan_equip" and card.type == Card.TypeEquip then match = true end
      if choice == "jianyan_red" and card.color == Card.Red then match = true end
      if choice == "jianyan_black" and card.color == Card.Black then match = true end
      
      if match then
        found_card = top_card
        break
      else
        -- 不符合的牌放入弃牌堆
        room:moveCardTo(top_card, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, xh__jianyan.name)
      end
    end
    
    if found_card then
      -- 选择一名男性角色
      local males = table.filter(room.alive_players, function(p)
        return p.gender == General.Male
      end)
      
      if #males > 0 then
        local to = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 1,
          targets = males,
          skill_name = xh__jianyan.name,
          prompt = "选择一名男性角色获得此牌",
          cancelable = false,
        })[1]
        
        room:moveCardTo(found_card, Player.Hand, to, fk.ReasonGive, xh__jianyan.name, nil, false, player.id)
      end
    end
  end,
})

-- 回合结束清除标记
jianyan:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@jianyan_used") ~= 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@jianyan_used", 0)
  end,
})

return jianyan
