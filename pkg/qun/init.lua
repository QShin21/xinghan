-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂 - 群雄武将包
local extension = Package:new("xinhan_qun")
extension.extensionName = "xinhanwujiang"

-- 加载技能
extension:loadSkillSkelsByPath("./packages/xinhanwujiang/pkg/qun/skills")

Fk:loadTranslationTable {
  ["xinhan_qun"] = "星汉灿烂·群",
}


return extension
