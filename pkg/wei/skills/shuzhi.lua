-- SPDX-License-Identifier: GPL-3.0-or-later
-- 曹操 - 述志技能
-- 游戏开始时，你选择获得"奸雄"或"清正"。

local shuzhi = fk.CreateSkill {
  name = "shuzhi",
}

Fk:loadTranslationTable {
  ["shuzhi"] = "述志",
  [":shuzhi"] = "游戏开始时，你选择获得\"奸雄\"或\"清正\"。",

  ["#shuzhi-choice"] = "述志：选择获得一个技能",
  ["shuzhi_jianxiong"] = "奸雄：受到伤害后，获得造成伤害的牌并摸一张牌",
  ["shuzhi_qingzheng"] = "清正：出牌阶段开始时，弃置一种花色的牌，令其他角色弃置同花色牌",

  ["$shuzhi1"] = "志在天下，何惧之有！",
  ["$shuzhi2"] = "大业未成，不敢懈怠！",
}

shuzhi:addEffect(fk.GameStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(shuzhi.name)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room

    local choice = room:askToChoice(player, {
      choices = {"shuzhi_jianxiong", "shuzhi_qingzheng"},
      skill_name = shuzhi.name,
      prompt = "#shuzhi-choice",
      detailed = true,
    })

    if choice == "shuzhi_jianxiong" then
      room:handleAddLoseSkills(player, "jianxiong", nil, false, true)
    else
      room:handleAddLoseSkills(player, "qingzheng", nil, false, true)
    end

    -- 移除述志
    room:handleAddLoseSkills(player, "-" .. shuzhi.name, nil, false, true)
  end,
})

return shuzhi
