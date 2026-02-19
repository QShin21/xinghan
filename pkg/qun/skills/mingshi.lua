-- SPDX-License-Identifier: GPL-3.0-or-later
-- 孔融 - 名士技能
-- 锁定技，当你受到伤害时，若伤害来源的手牌数大于你，其须选择一项：
-- 1.弃置一张手牌；2.令此伤害-1。

local mingshi = fk.CreateSkill {
  name = "xh__mingshi",
}

Fk:loadTranslationTable {
  ["xh__mingshi"] = "名士",
  [":xh__mingshi"] = "锁定技，当你受到伤害时，若伤害来源的手牌数大于你，其须选择一项："..
    "1.弃置一张手牌；2.令此伤害-1。",

  ["mingshi_discard"] = "弃置一张手牌",
  ["mingshi_reduce"] = "令此伤害-1",

  ["$xh__mingshi1"] = "名士之风，岂容侵犯！",
  ["$xh__mingshi2"] = "孔门之后，名士风流！",
}

mingshi:addEffect(fk.DamageInflicted, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(xh__mingshi.name) then return false end
    if not data.from or data.from:isNude() then return false end
    if data.from:getHandcardNum() <= player:getHandcardNum() then return false end
    return true
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local source = data.from
    
    local choice = room:askToChoice(source, {
      choices = {"mingshi_discard", "mingshi_reduce"},
      skill_name = xh__mingshi.name,
      prompt = "选择一项",
      detailed = false,
    })
    
    if choice == "mingshi_discard" then
      local id = room:askToCards(source, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = xh__mingshi.name,
        pattern = ".",
        prompt = "选择一张手牌弃置",
        cancelable = false,
      })
      room:throwCard(id, xh__mingshi.name, source, player)
    else
      data.damage = data.damage - 1
    end
  end,
})

return mingshi
