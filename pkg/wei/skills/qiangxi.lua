-- SPDX-License-Identifier: GPL-3.0-or-later
-- 典韦 - 强袭技能
-- 出牌阶段限一次，你可以受到1点伤害或弃置一张武器牌，对对手造成1点伤害。

local qiangxi = fk.CreateSkill {
  name = "qiangxi",
}

Fk:loadTranslationTable {
  ["qiangxi"] = "强袭",
  [":qiangxi"] = "出牌阶段限一次，你可以受到1点伤害或弃置一张武器牌，对对手造成1点伤害。",

  ["#qiangxi-use"] = "强袭：选择一项代价，对一名角色造成1点伤害",
  ["qiangxi_damage"] = "受到1点伤害",
  ["qiangxi_weapon"] = "弃置一张武器牌",
  ["#qiangxi-target"] = "强袭：选择一名角色造成1点伤害",

  ["$qiangxi1"] = "强袭敌阵，虽死无憾！",
  ["qiangxi2"] = "看我强袭！",
}

qiangxi:addEffect("active", {
  mute = true,
  prompt = "#qiangxi-use",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(qiangxi.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    return to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, qiangxi.name, "offensive", {target})
    player:broadcastSkillInvoke(qiangxi.name)

    local choices = {"qiangxi_damage"}
    
    -- 检查是否有武器牌
    local has_weapon = table.find(player:getCardIds("he"), function(id)
      return Fk:getCardById(id).sub_type == Card.SubtypeWeapon
    end)
    
    if has_weapon then
      table.insert(choices, "qiangxi_weapon")
    end

    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = qiangxi.name,
      prompt = "#qiangxi-use",
      detailed = false,
    })

    if choice == "qiangxi_damage" then
      room:loseHp(player, 1, qiangxi.name)
    else
      -- 弃置一张武器牌
      local weapon_cards = table.filter(player:getCardIds("he"), function(id)
        return Fk:getCardById(id).sub_type == Card.SubtypeWeapon
      end)
      
      local id = room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = qiangxi.name,
        pattern = tostring(Exppattern{ id = weapon_cards }),
        prompt = "选择一张武器牌弃置",
        cancelable = false,
      })
      
      room:throwCard(id, qiangxi.name, player, player)
    end

    if not target.dead then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = qiangxi.name,
      }
    end
  end,
})

return qiangxi
