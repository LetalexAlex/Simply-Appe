return function(player)
    local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
    local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
    local StepsOrTrail = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or pss:GetPlayedSteps()[1]
    
    local Profile = PROFILEMAN:GetProfile(player)
    local HighScoreList = Profile:GetHighScoreList(SongOrCourse, StepsOrTrail)
    local HighScores = HighScoreList:GetHighScores()
    
    if #HighScores == 0 then
        -- Fallback to Machine Profile if personal profile yields nothing
        HighScoreList = PROFILEMAN:GetMachineProfile():GetHighScoreList(SongOrCourse, StepsOrTrail)
        HighScores = HighScoreList:GetHighScores()
    end
    
    local personalIndex = pss:GetPersonalHighScoreIndex()
    if #HighScores > 0 and personalIndex == -1 then
        -- We fell back to machine profile, let's use machine index
        personalIndex = pss:GetMachineHighScoreIndex()
    end
    
    local previousHighScoreObj = nil
    
    if #HighScores > 0 then
        if personalIndex == 0 then
            -- They got a new #1 record! The old #1 is now at index 2.
            if #HighScores > 1 then
                previousHighScoreObj = HighScores[2]
            end
        else
            -- They did NOT get a new #1 record (or this is event mode and they didn't place).
            -- Their previous best score ever is still at index 1.
            -- Unless this was their VERY first time, but if personalIndex != 0, and #HighScores is 1, HighScores[1] is their current run.
            -- Wait, if they didn't place and it's their very first time... well if it's their first time they place PR1.
            -- Actually, if they failed on their 1st time, they might not get a PR.
            -- HighScores[1] is definitely the best score.
            -- BUT wait! If they failed their very first time, StepMania might save a failed score as HighScores[1].
            -- If HighScoreList includes the current run, we just check if it's the current run.
            previousHighScoreObj = HighScores[1]
        end
        
        -- One edge case: what if their current score IS HighScores[1] but it's their very first time playing?
        -- if #HighScores == 1 and personalIndex == 0, previousHighScoreObj will be nil (because HighScores[2] is nil). This correctly yields 0.00.
    end
    
    local prevStats = {
        percent = 0,
        exScore = 0,
        recordDate = "----",
        W0 = 0, W1 = 0, W2 = 0, W3 = 0, W4 = 0, W5 = 0, Miss = 0,
        Holds = 0, Mines = 0, Rolls = 0
    }
    
    if previousHighScoreObj then
        -- Percent is formatted as 98.56 (or 98,56 in some locales)
        local percentFormatted = FormatPercentScore(previousHighScoreObj:GetPercentDP()):gsub("%%", ""):gsub(",", ".")
        prevStats.percent = tonumber(percentFormatted) or 0
        
        prevStats.recordDate = previousHighScoreObj:GetDate()
        -- Push the base "TapNoteScore_W1" (Fantastics) into W0 (Flawless/Cyan Fantastic) 
        -- instead of W1 (White Fantastic) so the UI displays them properly for the user.
        -- Since W0 isn't explicitly saved by StepMania history, this ensures past best scores
        -- natively attribute their Fantastics to the best tier.
        prevStats.W0 = previousHighScoreObj:GetTapNoteScore("TapNoteScore_W1") or 0
        prevStats.W1 = 0
        prevStats.W2 = previousHighScoreObj:GetTapNoteScore("TapNoteScore_W2") or 0
        prevStats.W3 = previousHighScoreObj:GetTapNoteScore("TapNoteScore_W3") or 0
        prevStats.W4 = previousHighScoreObj:GetTapNoteScore("TapNoteScore_W4") or 0
        prevStats.W5 = previousHighScoreObj:GetTapNoteScore("TapNoteScore_W5") or 0
        prevStats.Miss = previousHighScoreObj:GetTapNoteScore("TapNoteScore_Miss") or 0
        
        local radar = previousHighScoreObj:GetRadarValues()
        if radar then
            prevStats.Holds = radar:GetValue("RadarCategory_Holds") or 0
            prevStats.Mines = radar:GetValue("RadarCategory_Mines") or 0
            prevStats.Rolls = radar:GetValue("RadarCategory_Rolls") or 0
        end
        
        -- To calculate EX score
        local counts = {
            W0 = prevStats.W0,
            W1 = prevStats.W1,
            W2 = prevStats.W2,
            W3 = prevStats.W3,
            W4 = prevStats.W4,
            W5 = prevStats.W5,
            Miss = prevStats.Miss
        }
        if CalculateExScore then
            prevStats.exScore = CalculateExScore(player, counts) or 0
        end
    end
    
    return prevStats
end
