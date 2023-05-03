GJailBan = GJailBan or {}

GJailBan.config = {}

--[[ Config starts here ]]

-- Weapons to give to prisoners, leave "{}" to not give any. Prisoners are only able to deal damage to other prisoners.
GJailBan.config.weapon = {}

-- Amount of ammunition prisoners should be given (has no effect if GJailBan.config.weapon={})
GJailBan.config.ammonb = 100

-- Set to true to allow prisoners and non-prisoners to speak together. Prisoners can always talk to other prisoners.
GJailBan.config.allowedToSpeak = true

-- Allow prisoners to close the information window
GJailBan.config.allowedToCloseInfo = false

-- Chat command to open Jailban menu, must have "ulx jailban" permission
GJailBan.config.menucommand = "!gbans"

-- Set language - "en" or "fr"
GJailBan.config.language = "en"

GJailBan.allPhrases = {
    ["fr"] = {
        ["gjailban.client.youarebanned"]="Vous avez été banni pour: ",
        ["gjailban.client.permaban"]="Vous êtes banni de manière permanente",
        ["gjailban.client.permabanlist"]="Joueur banni de manière permanente",
        ["gjailban.client.banlength"]="Temps restant: ",
        ["gjailban.client.d"]="j ",
        ["gjailban.client.menutitle"]="Liste des Jailbans",
        ["gjailban.client.unbanaction"]="Débannir",
        ["gjailban.server.toolname"]="Placeur de prison",
        ["gjailban.server.tooldesc"]="Permet de définir la zone de la prison pour les bannis",
        ["gjailban.server.toolleft1"]="Placer le premier coin de la prison",
        ["gjailban.server.toolleft2"]="Placer l'autre coin de la prison",
        ["gjailban.server.toolright"]="Sauvegarder la position de la prison",
        ["gjailban.server.toolreload"]="Réinitialiser la positon de la prison",
        ["gjailban.server.noreason"]="Aucune raison",
        ["gjailban.server.nojail"]="Vous ne pouvez pas jailban si vous n'avez pas mis en place la prison (Utilisez le toolgun) \n",   
    },
    ["en"] = {
        ["gjailban.client.youarebanned"]="You are banned for: ",
        ["gjailban.client.permaban"]="You are permanently banned",
        ["gjailban.client.permabanlist"]="The user is permanently banned",
        ["gjailban.client.banlength"]="Time left: ",
        ["gjailban.client.d"]="d ",
        ["gjailban.client.menutitle"]="Jailbans list",
        ["gjailban.client.unbanaction"]="Unban",
        ["gjailban.server.toolname"]="Jail positioner",
        ["gjailban.server.tooldesc"]="Used to define the jail zone for banned guys",
        ["gjailban.server.toolleft1"]="Place first jail corner",
        ["gjailban.server.toolleft2"]="Place the other jail corner",
        ["gjailban.server.toolright"]="Save jail position",
        ["gjailban.server.toolreload"]="Reset jail position",
        ["gjailban.server.noreason"]="No reason",
        ["gjailban.server.nojail"]="You can't jailban if you did not set up the jail before ! (Check the toolgun) \n",
    },
}

--[[ Config ends here ]]

--------------------------- Do not edit below ---------------------------

-- Init languages
GJailBan.phrases = GJailBan.allPhrases[GJailBan.config.language]

GJailBan.getPhrase = function(string)
    phrase = GJailBan.phrases[string]
    return phrase or string
end