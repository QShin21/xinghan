-- SPDX-License-Identifier: GPL-3.0-or-later
-- 星汉灿烂 - 吴国武将包
local extension = Package:new("xinhan_wu")
extension.extensionName = "xinhanwujiang"

-- 加载技能
extension:loadSkillSkelsByPath("./packages/xinhanwujiang/pkg/wu/skills")

Fk:loadTranslationTable {
  ["xinhan_wu"] = "星汉灿烂·吴",
}

-- 孙坚，男，吴，4/5勾玉
local sunjian = General:new(extension, "sunjian", "wu", 4, 5)
sunjian:addSkills { "yinghun" }
Fk:loadTranslationTable {
  ["sunjian"] = "孙坚",
  ["#sunjian"] = "江东猛虎",
  ["illustrator:sunjian"] = "KayaK",
  ["~sunjian"] = "有埋伏……呃……",
}

-- 黄盖，男，吴，4勾玉
General:new(extension, "huanggai", "wu", 4):addSkills { "kurou", "zhaxiang" }
Fk:loadTranslationTable {
  ["huanggai"] = "黄盖",
  ["#huanggai"] = "轻身为国",
  ["illustrator:huanggai"] = "KayaK",
  ["~huanggai"] = "再无……苦肉计了……",
}

-- 韩当，男，吴，4勾玉
General:new(extension, "handang", "wu", 4):addSkills { "gongqi", "jiefan" }
Fk:loadTranslationTable {
  ["handang"] = "韩当",
  ["#handang"] = "石城侯",
  ["illustrator:handang"] = "KayaK",
  ["~handang"] = "江东……",
}

-- 孙权，男，吴，4勾玉
General:new(extension, "sunquan", "wu", 4):addSkills { "zhiheng" }
Fk:loadTranslationTable {
  ["sunquan"] = "孙权",
  ["#sunquan"] = "年轻的贤君",
  ["illustrator:sunquan"] = "KayaK",
  ["~sunquan"] = "父亲，大哥，仲谋愧矣……",
}

-- 孙坚(新)，男，吴，4/5勾玉
local sunjian_new = General:new(extension, "sunjian_new", "wu", 4, 5)
sunjian_new:addSkills { "hulie" }
Fk:loadTranslationTable {
  ["sunjian_new"] = "孙坚",
  ["#sunjian_new"] = "江东猛虎",
  ["illustrator:sunjian_new"] = "KayaK",
  ["~sunjian_new"] = "有埋伏……呃……",
}

-- 孙策(吴)，男，吴，4勾玉
General:new(extension, "sunce", "wu", 4):addSkills { "jiang", "hunzi" }
Fk:loadTranslationTable {
  ["sunce"] = "孙策",
  ["#sunce"] = "江东小霸王",
  ["illustrator:sunce"] = "KayaK",
  ["~sunce"] = "内事不决问张昭，外事不决问周瑜……",
}

-- 周瑜，男，吴，3勾玉
General:new(extension, "zhouyu", "wu", 3):addSkills { "yingzi", "fanjian" }
Fk:loadTranslationTable {
  ["zhouyu"] = "周瑜",
  ["#zhouyu"] = "大都督",
  ["illustrator:zhouyu"] = "KayaK",
  ["~zhouyu"] = "既生瑜，何生亮……",
}

-- 庞统，男，吴，3勾玉
General:new(extension, "pangtong", "wu", 3):addSkills { "guolun", "zhanji" }
Fk:loadTranslationTable {
  ["pangtong"] = "庞统",
  ["#pangtong"] = "凤雏",
  ["illustrator:pangtong"] = "KayaK",
  ["~pangtong"] = "落凤坡……",
}

return extension
