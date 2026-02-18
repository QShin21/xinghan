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

  ["#qiaomeng-discard"] = "趫猛：你可以弃置 %dest 区域里的一张牌",

  ["$qiaomeng1"] = "白马将军，威震北疆！",
  ["$qiaomeng2"] = "乌桓胆寒，望风而逃！",
}

qiaomeng:addEffect(fk.Damage, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qiaomeng.name) and
      data.card and data.card.trueName == "slash" and
      data.to and data.to ~= player and not data.to.dead and
      not data.to:isAllNude()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = qiaomeng.name,
      prompt = "#qiaomeng-discard::" .. data.to.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to

    local id = room:askToChooseCard(player, {
      target = to,
      flag = "hej",
      skill_name = qiaomeng.name,
    })

    local card = Fk:getCardById(id)

    -- 记录是否为坐骑牌
    local is_mount = (card.sub_type == Card.SubtypeOffensiveRide or
                      card.sub_type == Card.SubtypeDefensiveRide)

    -- 弃置牌
    room:throwCard(id, qiaomeng.name, to, player)

    -- 若为坐骑牌，获得此牌
    if is_mount and not player.dead then
      -- 检查牌是否在弃牌堆
      if table.contains(room.discard_pile, id) then
        room:moveCardTo(id, Player.Hand, player, fk.ReasonPrey, qiaomeng.name)
      end
    end
  end,
})

return qiaomeng
