--[[
    API Entry Point
]]

local helpers = require("helpers.api")

local Api = {}

Api.normalizeFlags = helpers.normalizeFlags
Api.compilePattern = helpers.compilePattern

Api.test = require("api.test")(helpers)
Api.match = require("api.match")(helpers)

local matchAll, gmatch = require("api.matchAll")(helpers)
Api.matchAll = matchAll
Api.gmatch = gmatch

Api.find = require("api.find")(helpers)
Api.replace = require("api.replace")(helpers)
Api.split = require("api.split")(helpers)

Api.installHooks = require("api.install")

return Api
