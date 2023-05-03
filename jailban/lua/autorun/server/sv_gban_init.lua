AddCSLuaFile("g_ban/config.lua")

AddCSLuaFile("g_ban/client/cl_draw.lua")

resource.AddFile("materials/prisoner.png")

include("g_ban/config.lua")
include("g_ban/server/sv_gban.lua")
include("g_ban/server/sv_gban_sql_helper.lua")
