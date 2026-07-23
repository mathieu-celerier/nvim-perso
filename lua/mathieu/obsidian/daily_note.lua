local M = {}

local function parse_iso_date(date_str)
	local year, month, day = date_str:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
	if not year then
		return nil
	end

	return {
		year = tonumber(year),
		month = tonumber(month),
		day = tonumber(day),
	}
end

local function shift_iso_date(date_str, delta_days)
	local parts = parse_iso_date(date_str)
	if not parts then
		return nil
	end

	local timestamp = os.time({
		year = parts.year,
		month = parts.month,
		day = parts.day + delta_days,
		hour = 12,
	})

	return os.date("%Y-%m-%d", timestamp)
end

function M.render(date_str)
	local yesterday = shift_iso_date(date_str, -1)
	local tomorrow = shift_iso_date(date_str, 1)
	local now = os.date("%Y-%m-%d %H:%M")

	return {
		"---",
		"tags:",
		"  - DailyNotes",
		"  - Area/Research",
		"date: " .. date_str,
		"time: " .. now,
		"projects: []",
		"topics: []",
		"people: []",
		"papers: []",
		"---",
		"",
		string.format("<< [[%s|Yesterday]] | [[%s|Tomorrow]] >>", yesterday, tomorrow),
		"",
		"## Focus for Today",
		"",
		"- Main research goal:",
		"- Main writing or analysis goal:",
		"- Main admin or logistics goal:",
		"",
		"## Scheduled / Due",
		"",
		"```tasks",
		"not done",
		string.format("(due %s) OR (scheduled %s)", date_str, date_str),
		"shortmode",
		"```",
		"",
		"## Overdue",
		"",
		"```tasks",
		"not done",
		string.format("due before %s", date_str),
		"shortmode",
		"```",
		"",
		"## Completed Today",
		"",
		"```tasks",
		string.format("done %s", date_str),
		"shortmode",
		"```",
		"",
		"## Meetings / Events",
		"",
		"- [[Meeting note]]",
		"- [[Seminar or talk]]",
		"",
		"## Graph Promotion Targets",
		"",
		"- Paper to create or update: [[...]]",
		"- Topic to create or update: [[...]]",
		"- Concept to create or update: [[...]]",
		"- Project or idea to create or update: [[...]]",
		"- Person or venue to create or update: [[...]]",
		"",
		"## Research Progress",
		"",
		"- Worked on [[Project]]",
		"- Advanced [[Topic]]",
		"- Clarified [[Concept]]",
		"- Read [[Paper]]",
		"- Follow-up question: [[Open question]]",
		"",
		"## Notes Created / Updated",
		"",
		"- [[...]]",
		"- [[...]]",
		"",
		"## Ideas / Questions to Process",
		"",
		"- ...",
		"- ...",
		"",
		"## End-of-Day Synthesis",
		"",
		"- What changed in my understanding?",
		"- What is still unclear or blocked?",
		"- What should become a permanent note?",
		"- What is the next concrete step?",
		"",
		"## New Tasks",
		"",
		"- [ ] ...",
		"- [ ] ...",
		"",
		"## Scratch",
	}
end

function M.is_daily_note_path(path)
	return type(path) == "string" and path:find("3 Resources/Journal/Daily", 1, true) ~= nil
end

function M.is_iso_date(date_str)
	return parse_iso_date(date_str) ~= nil
end

return M
