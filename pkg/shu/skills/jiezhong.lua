-- SPDX-License-Identifier: GPL-3.0-or-later
-- 关平 - 竭忠技能
-- 限定技，出牌阶段开始时，你可以将手牌摸至体力上限。

local jiezhong = fk.CreateSkill {
  name = "xh__jiezhong",
  frequency = Skill.Limited,
}

Fk:loadTranslationTable {
  ["xh__jiezhong"] = "竭忠",
  [":xh__jiezhong"] = "限定技，出牌阶段开始时，你可以将手牌摸至体力上限。",

  ["#xh__jiezhong-invoke"] = "竭忠：将手牌摸至体力上限",

  ["$xh__jiezhong1"] = "竭忠尽智，死而后已！",
  ["$xh__jiezhong2"] = "忠心耿耿，义薄云天！",
}

jiezhong:addEffect(fk.EventPhaseStart, {
  anim_type = "draw",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xh__jiezhong.name) and
      player.phase == Player.Play and
      player:usedSkillTimes(xh__jiezhong.name) == 0 and
      player:getHandcardNum() < player.maxHp
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xh__jiezhong.name,
      prompt = "#jiezhong-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local draw_num = player.maxHp - player:getHandcardNum()
    player:drawCards(draw_num, xh__jiezhong.name)
  end,
})

return jiezhong
