-- SPDX-License-Identifier: GPL-3.0-or-later
-- 士燮 - 礼下技能
-- 锁定技，对手的准备阶段，若你不在其攻击范围内，该角色须选择一项：
-- 1.令你摸一张牌；2.弃置你装备区内的一张牌，该角色失去1点体力。

local lixia = fk.CreateSkill {
  name = "xh__lixia",
}

Fk:loadTranslationTable {
  ["xh__lixia"] = "礼下",
  [":xh__lixia"] = "锁定技，对手的准备阶段，若你不在其攻击范围内，该角色须选择一项："..
    "1.令你摸一张牌；2.弃置你装备区内的一张牌，该角色失去1点体力。",

  ["lixia_draw"] = "令其摸一张牌",
  ["lixia_discard"] = "弃置其装备区内的一张牌，你失去1点体力",

  ["$xh__lixia1"] = "礼下之士，以德服人！",
  ["$xh__lixia2"] = "士燮礼下，交州太平！",
}

lixia:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target == player or not player:hasSkill(xh__lixia.name) then return false end
    if target.phase ~= Player.Start then return false end
    
    -- 检查是否在攻击范围内
    return target:distanceTo(player) > target:getAttackRange()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    local choices = {"lixia_draw"}
    if #player:getCardIds("e") > 0 then
      table.insert(choices, "lixia_discard")
    end
    
    local choice = room:askToChoice(target, {
      choices = choices,
      skill_name = xh__lixia.name,
      prompt = "选择一项",
      detailed = false,
    })
    
    if choice == "lixia_draw" then
      player:drawCards(1, xh__lixia.name)
    else
      -- 弃置装备牌
      local id = room:askToChooseCard(target, {
        target = player,
        flag = "e",
        skill_name = xh__lixia.name,
      })
      room:throwCard(id, xh__lixia.name, player, target)
      
      -- 失去体力
      room:loseHp(target, 1, xh__lixia.name)
    end
  end,
})

return lixia
