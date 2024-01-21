local M = {}

---@class Score
---@field new fun(self: Score, complexity: (integer | nil), nest: (integer | nil)): Score
---@field __complexity integer
---@field __nest integer
local Score = {}
Score.__index = Score

---@param complexity integer | nil
---@param nest integer | nil
function Score:new(complexity, nest)
    return setmetatable({
        __complexity = complexity or 0,
        __nest = nest or 0,
    }, Score)
end

---@class ScoreController
-- +1 complexity
---@field increment fun(score: Score): integer
---@field get_complexity fun(score: Score): integer
-- +1 nest
---@field increment_nest fun(score: Score): integer
-- -1 nest
---@field decrement_nest fun(score: Score): integer
local score_controller = {
    increment = function(score)
        score.__complexity = score.__complexity + score.__nest + 1
        return score.__complexity
    end,
    get_complexity = function(score)
        return score.__complexity
    end,
    increment_nest = function(score)
        score.__nest = score.__nest + 1
        return score.__nest
    end,
    decrement_nest = function(score)
        score.__nest = score.__nest - 1
        return score.__nest
    end,
}

M.Score = Score
M.score_controller = score_controller

return M
