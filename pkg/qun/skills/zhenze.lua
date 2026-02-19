-- SPDX-License-Identifier: GPL-3.0-or-later
-- 公孙度 - 震泽技能
-- 弃牌阶段开始时，你可以选择一项：
-- 1.令所有手牌数和体力值的大小关系与你不同的角色失去1点体力；
-- 2.令所有手牌数和体力值的大小关系与你相同的角色摸一张牌。

local zhenze = fk.CreateSkill {
  name = "zhenze",
}

Fk:loadTranslationTable {
  ["zhenze"] = "震泽",
  [":zhenze"] = "弃牌阶段开始时，你可以选择一项："..
    "1.令所有手牌数和体力值的大小关系与你不同的角色失去1点体力；"..
    "2.令所有手牌数和体力值的大小关系与你相同的角色摸一张牌。",

  ["zhenze_damage"] = "令手牌数和体力值关系不同的角色失去1点体力",
  ["zhenze_draw"] = "令手牌数和体力值关系相同的角色摸一张牌",

  ["$zhenze1"] = "震泽之威，势不可挡！",
  ["$zhenze2"] = "辽东公孙，震泽天下！",
}

zhenze:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhenze.name) and
      player.phase == Player.Discard
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    
    local choice = room:askToChoice(player, {
      choices = {"zhenze_damage", "zhenze_draw"},
      skill_name = zhenze.name,
      prompt = "选择一项",
      detailed = false,
    })
    
    event:setCostData(self, {choice = choice})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    
    -- 计算自己的手牌数和体力值关系
    local self_relation = player:getHandcardNum() - player.hp
    
    for _, p in ipairs(room.alive_players) do
      if p ~= player then
        local p_relation = p:getHandcardNum() - p.hp
        local same = (self_relation > 0 and p_relation > 0) or
          (self_relation < 0 and p_relation < 0) or
          (self_relation == 0 and p_relation == 0)
        
        if choice == "zhenze_damage" then
          if not same then
            room:loseHp(p, 1, zhenze.name)
          end
        else
          if same then
            p:drawCards(1, zhenze.name)
          end
        end
      end
    end
  end,
})

return zhenze
