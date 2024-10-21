--[[
# MIT License
#
# Copyright (c) 2024 Garrick Aden-Buie
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
]]

local formatMapping = {
  year = "%Y",
  month = "%B",
  day = "%d",
  weekday = "%A",
  hour = "%I",
  minute = "%M",
  ampm = "%p",
  date = "%x",
  time = "%X",
  datetime = "%c",
  isodate = "%F",
  isotime = "%T",
  isodatetime = "%FT%T%z",
  timestamp = "%F %T"
}

local function run_command(command)
  local handle, err = io.popen(command)
  if not handle then
    quarto.log.error("Error running command `" .. command .. "`: " .. err)
    return nil
  end
  local result = handle:read("*a")
  handle:close()
  return result
end

local function last_modified_bsd(file)
  local command = "stat -f %m " .. file  -- Command to get modification time
  local result = run_command(command)
  return tonumber(result)
end

local function last_modified_linux(file)
  local command = "stat -c %y " .. file  -- Command to get modification time

  local result = run_command(command)
  if result == nil then
    return nil
  end

  -- Extract modification time string
  local mod_time_str = string.match(result, "(%d+%-%d+%-%d+ %d+:%d+:%d+)")
  if mod_time_str == nil then
    quarto.log.error(
      "Error parsing the file modification time string, " ..
      "defaulting to render time."
    )
    return nil
  end

  local mod_time_pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
  local year, month, day, hour, min, sec = mod_time_str:match(mod_time_pattern)
  if not (year and month and day and hour and min and sec) then
    quarto.log.error(
      "Error parsing the file modification time string, " ..
      "defaulting to render time."
    )
    return nil
  end

  return os.time{year=year, month=month, day=day, hour=hour, min=min, sec=sec}
end

local last_modified_fns = {
  linux = last_modified_linux,
  bsd = last_modified_bsd,
  darwin = last_modified_bsd
}

local function parse_modified_date(meta)
  if meta.modified == nil then
    return nil
  end

  local dt = pandoc.utils.stringify(meta.modified)

  -- Parsing the date string
  local year, month, day = dt:match("(%d%d%d%d)-(%d%d)-(%d%d)")
  if not (year and month and day) then
    quarto.log.error("Invalid `modified` date format. Please use the format 'YYYY-MM-DD HH:MM:SS'")
    return nil
  end

  -- parse the time in pieces so we can handle missing parts
  local hour = dt:match("%d%d%d%d-%d%d-%d%d[ T]?(%d+)")
  local min  = dt:match("%d%d%d%d-%d%d-%d%d[ T]?%d+:(%d+)")
  local sec  = dt:match("%d%d%d%d-%d%d-%d%d[ T]?%d+:%d+:(%d+)")

  -- Convert to a time object
  return os.time{
    year=year,
    month=month,
    day=day,
    hour=hour or 0,
    min=min or 0,
    sec=sec or 0
  }
end

local function source_modified_time()
  local file = quarto.doc.input_file
  local last_modified = last_modified_fns[pandoc.system.os](file)

  return last_modified
end

local function get_format(args)
  local format = formatMapping[args[1]] or args[1] or "%F %T"
  format = pandoc.utils.stringify(format)
  return format
end

---@param format string The format string, see https://www.lua.org/pil/22.1.html
---@param mod_time integer?
---@return pandoc.Str
local function format_time(format, mod_time)
  local now = os.date(format, mod_time)
  return pandoc.Str(tostring(now))
end

return {
  ['now'] = function(args)
    local format = get_format(args)
    return format_time(format)
  end,
  ['modified'] = function(args, _, meta)
    local format = get_format(args)

    local modified = parse_modified_date(meta)
    if modified then
      return format_time(format, modified)
    end

    local os = pandoc.system.os
    if last_modified_fns[os] == nil then
      quarto.log.warning(
        '`modified` shortcode can\'t automatically discover ' ..
        'the file modification time on "' .. os ..
        '", using rendered time instead. You can manually set the ' ..
        '`modified` date in the metadata to avoid this warning.'
      )
      return format_time(format)
    end

    mod_time = source_modified_time()
    return format_time(format, mod_time)
  end
}
