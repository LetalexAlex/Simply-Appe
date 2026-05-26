local json_path = THEME:GetCurrentThemeDirectory() .. "srpg_data.json"

local function LoadFirstRow()
	if FILEMAN:DoesFileExist(json_path) then
		local content = lua.ReadFile(json_path)
		if content and #content > 0 then
			local data = JsonDecode(content)
			if data and #data > 0 then
				return data[1]
			end
		end
	end
	return nil
end

local af = Def.ActorFrame{
	InitCommand=function(self) self:visible(false) end,
	ShowSRPG9Command=function(self)
		self:visible(true)
		local row = LoadFirstRow()
		if row then
			self:playcommand("SetData", row)
		else
			self:playcommand("SetData", {
				title = "No data found",
				bpm_base = "-",
				diff = "-",
				rate = "-",
				score = "-",
				duration_sec = "-",
				xp = "-"
			})
		end
	end,
	HideSRPG9Command=function(self) self:visible(false) end,

	-- Dark background covering the full screen
	Def.Quad{
		InitCommand=function(self) self:FullScreen():diffuse(0,0,0,0.85) end
	},

	-- Center Panel/Card Frame
	Def.ActorFrame{
		InitCommand=function(self) self:xy(_screen.cx, _screen.cy) end,

		-- Card border
		Def.Quad{
			InitCommand=function(self) self:zoomto(524, 224):diffuse(Color.White) end
		},
		-- Card background
		Def.Quad{
			InitCommand=function(self) self:zoomto(520, 220):diffuse(Color.Black) end
		},

		-- Title
		Def.BitmapText{
			Font="Common Bold",
			Text="SRPG9 Companion",
			InitCommand=function(self) self:y(-130):zoom(0.9):diffuse(Color.White) end
		},

		-- Table Headers
		Def.BitmapText{ Font="Common Normal", Text="TITLE", InitCommand=function(self) self:xy(-240, -60):zoom(0.5):horizalign(left):diffuse(color("#aaaaff")) end },
		Def.BitmapText{ Font="Common Normal", Text="BPM",   InitCommand=function(self) self:xy(-45, -60):zoom(0.5):horizalign(right):diffuse(color("#aaaaff")) end },
		Def.BitmapText{ Font="Common Normal", Text="DIFF",  InitCommand=function(self) self:xy(5, -60):zoom(0.5):horizalign(right):diffuse(color("#aaaaff")) end },
		Def.BitmapText{ Font="Common Normal", Text="RATE",  InitCommand=function(self) self:xy(55, -60):zoom(0.5):horizalign(right):diffuse(color("#aaaaff")) end },
		Def.BitmapText{ Font="Common Normal", Text="SCORE", InitCommand=function(self) self:xy(115, -60):zoom(0.5):horizalign(right):diffuse(color("#aaaaff")) end },
		Def.BitmapText{ Font="Common Normal", Text="TIME",  InitCommand=function(self) self:xy(175, -60):zoom(0.5):horizalign(right):diffuse(color("#aaaaff")) end },
		Def.BitmapText{ Font="Common Normal", Text="XP",    InitCommand=function(self) self:xy(240, -60):zoom(0.5):horizalign(right):diffuse(color("#aaaaff")) end },

		-- Separator Line
		Def.Quad{
			InitCommand=function(self) self:y(-45):zoomto(490, 1):diffuse(0.5,0.5,0.5,0.8) end
		},

		-- Data Row (First Song)
		Def.BitmapText{
			Font="Common Normal",
			InitCommand=function(self) self:xy(-240, -15):zoom(0.75):horizalign(left):maxwidth(185) end,
			SetDataCommand=function(self, row) self:settext(row.title) end
		},
		Def.BitmapText{
			Font="Common Normal",
			InitCommand=function(self) self:xy(-45, -15):zoom(0.75):horizalign(right) end,
			SetDataCommand=function(self, row) self:settext(tostring(row.bpm_base)) end
		},
		Def.BitmapText{
			Font="Common Normal",
			InitCommand=function(self) self:xy(5, -15):zoom(0.75):horizalign(right) end,
			SetDataCommand=function(self, row) self:settext(tostring(row.diff)) end
		},
		Def.BitmapText{
			Font="Common Normal",
			InitCommand=function(self) self:xy(55, -15):zoom(0.75):horizalign(right) end,
			SetDataCommand=function(self, row) self:settext(tostring(row.rate)) end
		},
		Def.BitmapText{
			Font="Common Normal",
			InitCommand=function(self) self:xy(115, -15):zoom(0.75):horizalign(right) end,
			SetDataCommand=function(self, row) self:settext(tostring(row.score)) end
		},
		Def.BitmapText{
			Font="Common Normal",
			InitCommand=function(self) self:xy(175, -15):zoom(0.75):horizalign(right) end,
			SetDataCommand=function(self, row) self:settext(tostring(row.duration_sec)) end
		},
		Def.BitmapText{
			Font="Common Normal",
			InitCommand=function(self) self:xy(240, -15):zoom(0.75):horizalign(right) end,
			SetDataCommand=function(self, row) self:settext(tostring(row.xp)) end
		},

		-- Press Enter back prompt
		Def.BitmapText{
			Font="Common Bold",
			Text="Press ENTER to go back",
			InitCommand=function(self) self:y(75):zoom(0.7) end,
			OnCommand=function(self)
				self:diffuseshift():effectcolor1(1,1,1,1):effectcolor2(0.5,0.5,0.5,1):effectperiod(1.5)
			end
		}
	}
}

return af
