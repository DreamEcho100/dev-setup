-- Every N-th Neovim start, ask GitHub whether upstream molten-nvim has commits
-- that the fork branch used in plugins/molten.lua doesn't have yet, and show a
-- toast if so. Notify only: updating is `de100-molten-fork-sync`.
--
-- Settings (vim.g, set before startup finishes):
--   de100_molten_upstream_check_every  check on every N-th start (default 10, 0 = never)
--   de100_molten_upstream_base         compare base, "<owner>:<branch>" or a sha
--                                      (default: the fork branch; override for testing)
local M = {}

local UPSTREAM = "benlubas:main"
local FORK_BRANCH = "DreamEcho100:fix/inline-image-offset"
local API = "https://api.github.com/repos/benlubas/molten-nvim/compare/"

local function state_path()
    local dir = vim.fn.stdpath("state") .. "/de100"
    vim.fn.mkdir(dir, "p")
    return dir .. "/molten-upstream-check.json"
end

local function read_state()
    local f = io.open(state_path())
    if not f then return {} end
    local ok, data = pcall(vim.json.decode, f:read("*a"))
    f:close()
    return ok and type(data) == "table" and data or {}
end

local function write_state(state)
    local f = io.open(state_path(), "w")
    if not f then return end
    f:write(vim.json.encode(state))
    f:close()
end

--- Asks GitHub which upstream commits the base lacks. `on_result(count, titles, url)`
--- is only called on success; network or API failures stay silent.
function M.fetch(base, on_result)
    local url = API .. base .. "..." .. UPSTREAM
    vim.system({"curl", "-fsS", "--max-time", "10", url}, {text = true}, function(res)
        if res.code ~= 0 then return end
        local ok, data = pcall(vim.json.decode, res.stdout)
        if not ok or type(data) ~= "table" or not data.ahead_by then return end
        local titles = {}
        for _, commit in ipairs(data.commits or {}) do
            local title = (commit.commit.message or ""):match("^[^\n]*")
            table.insert(titles, title)
        end
        vim.schedule(function() on_result(data.ahead_by, titles, data.html_url, data.merge_base_commit) end)
    end)
end

local function notify_changes(count, titles, url)
    local lines = {
        ("molten-nvim upstream has %d new commit%s your fork branch lacks:"):format(
            count, count == 1 and "" or "s")
    }
    for i = math.max(1, #titles - 4), #titles do
        table.insert(lines, "  - " .. titles[i])
    end
    if #titles > 5 then table.insert(lines, ("  ... and %d older"):format(#titles - 5)) end
    table.insert(lines, "Update with: de100-molten-fork-sync")
    if url then table.insert(lines, url) end
    vim.notify(table.concat(lines, "\n"), vim.log.levels.WARN, {title = "molten-nvim upstream"})
end

--- Counts this start and, on every N-th one, runs the check.
---@param force boolean|nil  skip the counter (used by :MoltenUpstreamCheck)
function M.run(force)
    local every = vim.g.de100_molten_upstream_check_every
    if every == nil then every = 10 end
    if not force and every <= 0 then return end

    local state = read_state()
    state.opens = (state.opens or 0) + 1
    local due = force or state.opens % every == 0
    write_state(state)
    if not due then return end

    local base = vim.g.de100_molten_upstream_base or FORK_BRANCH
    M.fetch(base, function(count, titles, url)
        local current = read_state()
        local head = titles[#titles] or ""
        if count == 0 then
            if force then vim.notify("molten-nvim: fork branch is up to date with upstream main") end
            return
        end
        -- Only repeat the toast when upstream moved since the last one.
        if not force and current.last_notified == count .. ":" .. head then return end
        current.last_notified = count .. ":" .. head
        write_state(current)
        notify_changes(count, titles, url)
    end)
end

function M.setup()
    vim.api.nvim_create_user_command("MoltenUpstreamCheck", function() M.run(true) end, {
        desc = "Check upstream molten-nvim for commits missing from the fork branch"
    })
    vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function() vim.defer_fn(function() M.run(false) end, 3000) end
    })
end

return M
