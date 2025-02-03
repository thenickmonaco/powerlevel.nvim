--[[ 
Future implementation ideas
    - Make program more functional (very hard to read currently)
    - Auto update when user makes edits
    - allow user to modify how much power level
    increases based on TODO item ("weight", +5, +3, +1...)
    - ASCII animation of Goku going super saiyan that plays
    when power level increases
    - Animation changes based off power level (SSJ1 = 0 < PowerLevel
    < 100; SSJ2 = 100 < PowerLevel < 200...)
    - allow use for other file types? 
    - Separate into different functions
--]]

--[[ 
Description:

Function specific to markdown files in which Todo lists 
may be formatted to track the number of tasks completed.
Stores the total number of tasks completed (# header) as a 
"Total Power Level" and total number of tasks for subheaders
(## header) as a "Power Level". Then, plays an ASCII animation
in the current file of Goku going super saiyan for a couple of seconds.

Example format (.md):
# Todo list (Total Power Level: 23)

## Cooking (Power Level: 3)
- [1] cook omelette
- [1] poached egg
- [1] gordon ramsay steak

## Health (Power Level: 20)
- [20] workout
...

IMPORTANT: 
The Todo list file should be formatted 
as follows to ensure expected functionality:
...
... (Total Power Level: 0) ...
...
... (Power Level: 0) ...
...
... [0] ...
... [0] ...
...
--]]
function PowerLevel()

    -- must use markdown file
    local fileType = vim.bo.filetype
    if (fileType ~= 'markdown') then
        print('Not a markdown file; Can\'t update power level')
        return
    end

    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local cursorPos = vim.api.nvim_win_get_cursor(0)

    -- so many variables
    local tpl = 'Total Power Level: '
    local pl = 'Power Level: '
    local total = {}
    local power = {}
    local powerCount = 0
    local totalLineIndex = 0
    local powerLineIndex = 0
    local sum = 0
    local partialSum = 0

    OriginalPower = 0

    -- hard to read
    for i, line in ipairs(lines) do
        local totalLine, powerLine = false, false
        for j = 1, #line do
            local c = line:sub(j, j)
            if c == '(' then
                totalLine = line:sub(j + 1, j + 19) == tpl
                powerLine = line:sub(j + 1, j + 13) == pl
                if totalLine then
                    -- to determine if new power > original power
                    OriginalPower = lines[i]:sub(string.find(lines[i], tpl)
                    + string.len(tpl) - 1,
                    string.find(lines[i], ')') - 1) + 0
                end
            elseif c == '[' then
                -- want number of times task has been completed
                local num = string.match(line, '%[(%d+)%]')
                if (num) then
                    partialSum = partialSum + num
                end
            end
        end
        if totalLine then
            totalLineIndex = i
            total[totalLineIndex] = sum
        end
        if powerLine and powerCount == 0 then
            powerCount = powerCount + 1
            power[i] = partialSum
            powerLineIndex = i
        end
        if powerLine and powerCount > 0 or i >= #lines then
            sum = sum + partialSum
            total[totalLineIndex] = sum
            power[powerLineIndex] = partialSum
            powerLineIndex = i
            partialSum = 0
            powerCount = powerCount + 1
        end
    end

    NewPower = sum

    -- update lines
    for k, v in pairs(total) do
        local tplStart = string.find(lines[k], tpl)
        local tplEnd = string.find(lines[k], ')')
        local totalLine = lines[k]:sub(1, tplStart + string.len(tpl) - 1) ..
            v .. lines[k]:sub(tplEnd, string.len(lines[k]))
        lines[k] = totalLine
    end

    for k, v in pairs(power) do
        local plStart = string.find(lines[k], pl)
        local plEnd = string.find(lines[k], ')')
        local totalLine = lines[k]:sub(1, plStart + string.len(pl) - 1) ..
            v .. lines[k]:sub(plEnd, string.len(lines[k]))
        lines[k] = totalLine
    end

    -- ASCII animation
    local animationName = 'dragon-ball-z-goku'
    local dir = '/home/manslayer/Downloads/animations/' .. animationName .. '/'
    local frames = {}

    -- function to read a file's contents
    local function readFile(filePath)
        local file = io.open(filePath, "r")  -- Open file in read mode
        if not file then
            print("Error: Could not open file " .. filePath)
            return ""
        end
        local content = file:read("*a")      -- Read entire file
        file:close()                         -- Close the file
        return content
    end

    -- load each frame from the file paths (current frame count = 127) 
    local i = 0
    while (i <= 127) do -- original = 127
        local frameContent = readFile(dir .. animationName .. '-' .. i .. '.png.txt')
        table.insert(frames, frameContent)
        i = i + 1
    end

    -- play animation (reversed if decreasing power)
    local delay = 0.01 -- original = 0.01
    if (NewPower >= OriginalPower) then
        for _, frame in ipairs(frames) do
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(frame, "\n"))
            vim.cmd("redraw")
            vim.cmd("sleep " .. math.floor(delay * 1000) .. "m")
        end
    elseif (OriginalPower > NewPower) then
        for k = #frames, 1, -1 do
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(frames[k], "\n"))
            vim.cmd("redraw")
            vim.cmd("sleep " .. math.floor(delay * 1000) .. "m")
        end
    end

    -- update power levels
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.cmd("cal cursor(" .. cursorPos[1]  .. ", " .. cursorPos[2] .. ")")
end
