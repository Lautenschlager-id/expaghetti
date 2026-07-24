--[[
    API Entry Point
]]

local utils = require("api.utils")

local Api = {}

Api.normalizeFlags = utils.normalizeFlags
Api.compilePattern = utils.compilePattern

Api.test = require("api.test")(utils)
Api.match = require("api.match")(utils)

local matchAll, gmatch = require("api.matchAll")(utils)
Api.matchAll = matchAll
Api.gmatch = gmatch

Api.find = require("api.find")(utils)
Api.replace = require("api.replace")(utils)
Api.split = require("api.split")(utils)

Api.installHooks = require("api.install")

return Api
