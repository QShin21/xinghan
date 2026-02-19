-- SPDX-License-Identifier: GPL-3.0-or-later
-- 贾诩 - 完杀技能
-- 锁定技，当其他角色于你的回合内进入濒死状态时，你令其死亡。

local wansha = fk.CreateSkill {
  name = "xh__wansha",
}

Fk:loadTranslationTable {
  ["xh__wansha"] = "完杀",
  [":xh__wansha"] = "锁定技，当其他角色于你的回合内进入濒死状态时，你令其死亡。",

  ["$xh__wansha1"] = "神仙难救，必死无疑！",
  ["$xh__wansha2"] = "我要你三更死，谁敢留人到五更！",
}

wansha:addEffect(fk.EnterDying, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(wansha.name) and target ~= player and
      player.room.current == player
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})

    -- 令其死亡
    room:enterDying({
      who = target,
      force = true,
    })
  end,
})

return wansha
