local table_gen = require("lib/table_gen/table_gen")
local http_request = require("http.request")
local json = require("json")
local colorize = require("lib/ansicolors/ansicolors")

local headings
local rows = {}

local games = {}

local RATINGS = {start = 3, other = 2, stop = nil}
local NO_RANKING = "N/A"

local settings = {
	verbose = false,
}
local largest_rating = 0
local best_rating = {}

local function print_help()
	print(
		"Usage:\n\tlua ./ld-results.lua <option1> <option2> ...\n" ..
		"\tlua ./ld-results.lua --verbose 48/backwards-quest 47/pis-great-escape-1\n\n" ..
		"Avaliable options:\n" ..
		"\t--verbose (-v): Print extra ranking info\n" ..
		"\t<game link>: Game to add to the output table. You can copy this from your game url. Example: `48/backwards-quest`"
	)
end

if #arg < 1 then
	print_help()
	return
end

for idx, cmd in ipairs(arg) do
	if cmd == "-v" or cmd == "--verbose" then
		settings.verbose = true
	elseif cmd == "-s" or cmd == "--style" then
		settings.style = arg[idx+1]
	elseif cmd:match("^-") then
		print_help()
		return
	else
		table.insert(games, cmd)
	end
end

headings = {
	"LD",
	"Game",
	settings.verbose and "Overall" or "All",
	"Fun",
	settings.verbose and "Innovation" or "Innov",
	"Theme",
	settings.verbose and "Graphics" or "Graph",
	"Audio",
	"Humor",
	"Mood"
}
RATINGS.stop = #headings

local function get_page(url)
	local headers, stream = http_request.new_from_uri(url):go(15)

	if not headers then
		print("This seems to be taking too long, retrying...")
		return get_page(url)
	end

	local result = assert(stream:get_body_as_string())
	if headers:get(":status") ~= "200" then
		error(result)
	end

	return json.decode(result)
end

local function fit_x_to_y_with_extra(x, y)
	local out = x

	while tostring(out):len() <= tostring(y):len() do
		out = out .. "#"
	end

	return out
end

local function biased_round(num)
	return math.ceil(num + 0.3) - 1
end

local function populate_row(num, gamepath)
	gamepath = string.match(gamepath, "^/?(%d-/.-)/?$") -- result: <ld_num>/<game-name>

	if not gamepath then
		print_help()
		return false
	end

	local game_info = get_page("https://api.ldjam.com/vx/node2/walk/1/events/ludum-dare/" .. gamepath .. "?node")
	local ld_info   = get_page("https://api.ldjam.com/vx/stats/"..game_info.node[1].parent)

	assert(game_info.node[1].magic, "Invalid game link given: `"..gamepath.."`")

	local verbose_extra = ", " .. game_info.node[1].subsubtype:match("^(.)")

	if settings.verbose then
		verbose_extra = ", " .. game_info.node[1].subsubtype
	end

	rows[num] = {
		gamepath:match("^(.-)/") .. verbose_extra,
		game_info.node[1].name,
		game_info.node[1].magic["grade-01-result"] or NO_RANKING,
		game_info.node[1].magic["grade-02-result"] or NO_RANKING,
		game_info.node[1].magic["grade-03-result"] or NO_RANKING,
		game_info.node[1].magic["grade-04-result"] or NO_RANKING,
		game_info.node[1].magic["grade-05-result"] or NO_RANKING,
		game_info.node[1].magic["grade-06-result"] or NO_RANKING,
		game_info.node[1].magic["grade-07-result"] or NO_RANKING,
		game_info.node[1].magic["grade-08-result"] or NO_RANKING,
	}

	for i=RATINGS.start, RATINGS.stop, 1 do
		local rating = rows[num][i]

		local total_submitted_in_cat = ld_info.stats[game_info.node[1].subsubtype]
		local total_games = ld_info.stats.game - ld_info.stats.unfinished
		local extra = 1.0 + (total_submitted_in_cat/total_games)
		local estimated_percent_games_rated = (ld_info.stats["grade-20-plus"] / total_games) * (game_info.node[1].subsubtype == "compo" and extra or 1)

		local total_rated_games = total_submitted_in_cat * (estimated_percent_games_rated)

		assert(
			total_rated_games <= total_submitted_in_cat,
			"My estimations are seriously flawed, please open a bug report and provide me with the command you ran"
		)

		if rating ~= NO_RANKING then
			local percentage = biased_round( (1 - (rating/total_rated_games)) * 100 )

			if not best_rating[headings[i]:lower()] then
				best_rating[headings[i]:lower()] = {}
			end

			if percentage > (best_rating[headings[i]:lower()].val or 0) then
				best_rating[headings[i]:lower()] = {val = percentage, row = num, idx = i}
			end

			if percentage > largest_rating then
				largest_rating = percentage
			end

			if settings.verbose then
				rows[num][i] = string.format("%4d/%4d - %d%%", rating, math.ceil(total_rated_games), percentage)
			else
				rows[num][i] = string.format("%d%%", percentage)
			end
		end
	end

	return true
end

table.sort(games, function(a, b)
	return tonumber(a:match("^(.-)/")) < tonumber(b:match("^(.-)/"))
end)

for idx, gamelink in ipairs(games) do
	if not gamelink:match("^-") then
		print("Getting info for `" .. gamelink .. "`...")
		if not populate_row(idx, gamelink) then
			return
		end
		print("Done!\n")
	end
end

largest_rating = tostring(largest_rating):len()

print("Generating table...")

-- mark best rating in a category to be colorized green
for _, data in pairs(best_rating) do
	if data.val then
		if settings.verbose then
			rows[data.row][data.idx] = rows[data.row][data.idx]:gsub("(/[ %d]- %- )%d-%%", "%1"..fit_x_to_y_with_extra(data.idx, data.val))
		else
			rows[data.row][data.idx] = rows[data.row][data.idx]:gsub("%d-%%", fit_x_to_y_with_extra(data.idx, data.val))
		end
	end
end

local table_out = table_gen(rows, headings, {style = "Unicode (Single Line)", value_justify = "center"})

print("DONE!\n")

print(
	"Format of ratings: " ..
	(
		settings.verbose
		and
		"`x/x`: (`ranking as seen on website`)`/`(`estimated total games rated 20+` (in category you submitted to))\n"
		or
		""
	) ..
	"`x%`: (`position in ratings, percentage form`, with 100% being 1st place and 0% being last)"
)

for _, data in pairs(best_rating) do
	if data.val then
		if settings.verbose then
			table_out = table_out:gsub(
				"(%d-/[ %d]- %- )" .. fit_x_to_y_with_extra(data.idx, data.val),
				"%%{bright green underline}%1" .. data.val .. "%%%%{reset}",
			1)
		else
			table_out = table_out:gsub(
				fit_x_to_y_with_extra(data.idx, data.val),
				"%%{bright green underline}" .. data.val .. "%%%%{reset}",
			1)
		end
	end
end

print("\n```\nNote that the rating percentage is only a rough guess.")
print(colorize(table_out) .. "\n```")
print("(Made with https://github.com/LoneWolfHT/ld-results-history)\n")
