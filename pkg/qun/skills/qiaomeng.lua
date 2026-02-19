-- SPDX-License-Identifier: GPL-3.0-or-later
-- 公孙瓒 - 趫猛技能
-- 当你使用【杀】对一名其他角色造成伤害后，你可以弃置其区域里的一张牌；
-- 当此牌置入弃牌堆后，若此牌为坐骑牌，你获得此牌。

local qiaomeng = fk.CreateSkill {
  name = "qiaomeng",
}

Fk:loadTranslationTable {
  ["qiaomeng"] = "趫猛",
  [":qiaomeng"] = "当你使用【杀】对一名其他角色造成伤害后，你可以弃置其区域里的一张牌；"..
    "当此牌置入弃牌堆后，若此牌为坐骑牌，你获得此牌。",

  ["#qiaomeng-discard"] = "趫猛：是否弃置其一张牌？",

  ["$qiaomeng1"] = "趫猛之姿，勇冠三军！",
  ["$qiaomeng2"] = "白马将军，威震边疆！",
}

qiaomeng:addEffect(fk.Damage, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(qiaomeng.name) then return false end
    if not data.card or data.card.trueName ~= "slash" then return false end
    if not data.to or data.to:isNude() then return false end
    return true
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = qiaomeng.name,
      prompt = "#qiaomeng-discard",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    
    local id = room:askToChooseCard(player, {
      target = to,
      flag = "he",
      skill_name = qiaomeng.name,
    })
    
    local card = Fk:getCardById(id)
    room:throwCard(id, qiaomeng.name, to, player)
    
    -- 如果是坐骑牌，获得之
    if card.sub_type == Card.SubtypeDefensiveRide or card.sub_type == Card.SubtypeOffensiveRide then
      if table.contains(room.discard_pile, id) then
        room:moveCardTo(id, Player.Hand, player, fk.ReasonPrey, qiaomeng.name)
      end
    end
  end,
})

return qiaomeng
