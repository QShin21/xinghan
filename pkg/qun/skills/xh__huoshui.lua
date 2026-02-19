-- SPDX-License-Identifier: GPL-3.0-or-later
-- 邹氏 - 祸水技能
-- 准备阶段，你可以令对手依次执行X项效果（X为你已损失的体力值且至少为1）：
-- 1.本回合非锁定技失效；2.交给你1张手牌；3.弃置装备区里的所有牌。

local huoshui = fk.CreateSkill {
  name = "xh__huoshui",
}

Fk:loadTranslationTable {
  ["xh__huoshui"] = "祸水",
  [":xh__huoshui"] = "准备阶段，你可以令对手依次执行X项效果（X为你已损失的体力值且至少为1）："..
    "1.本回合非锁定技失效；2.交给你1张手牌；3.弃置装备区里的所有牌。",

  ["#xh__huoshui-invoke"] = "祸水：是否发动？",
  ["huoshui_disable"] = "非锁定技失效",
  ["huoshui_give"] = "交给你1张手牌",
  ["huoshui_discard"] = "弃置装备区里的所有牌",

  ["$xh__huoshui1"] = "祸水红颜，倾国倾城！",
  ["$xh__huoshui2"] = "邹氏祸水，天下大乱！",
}

huoshui:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(huoshui.name) then return false end
    if player.phase ~= Player.Start then return false end
    
    local lost_hp = player.maxHp - player.hp
    return lost_hp > 0
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = huoshui.name,
      prompt = "#xh__huoshui-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local lost_hp = player.maxHp - player.hp
    
    local effects = {"huoshui_disable", "huoshui_give", "huoshui_discard"}
    
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if p.dead then goto continue end
      
      local count = math.min(lost_hp, #effects)
      
      for i = 1, count do
        local effect = effects[i]
        
        if effect == "huoshui_disable" then
          room:addPlayerMark(p, "@@huoshui_disable", 1)
        elseif effect == "huoshui_give" then
          if not p:isKongcheng() then
            local id = room:askToCards(p, {
              min_num = 1,
              max_num = 1,
              include_equip = false,
              skill_name = huoshui.name,
              pattern = ".",
              prompt = "选择一张手牌交给" .. player.name,
              cancelable = false,
            })
            room:moveCardTo(id, Player.Hand, player, fk.ReasonGive, huoshui.name, nil, false, p.id)
          end
        else
          local equip_cards = p:getCardIds("e")
          if #equip_cards > 0 then
            room:throwCard(equip_cards, huoshui.name, p, player)
          end
        end
      end
      
      ::continue::
    end
  end,
})

-- 非锁定技失效
huoshui:addEffect("filter", {
  card_filter = function(self, card, player)
    if player:getMark("@@huoshui_disable") > 0 then
      return card.skill and not card.skill.frequency == Skill.Lock
    end
    return false
  end,
})

-- 回合结束清除标记
huoshui:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@huoshui_disable") > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@huoshui_disable", 0)
  end,
})

return huoshui
