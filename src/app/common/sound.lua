--设置音量
local musicVolume = cc.UserDefault:getInstance():getIntegerForKey("MusicVolume",-1)
local soundVolume = cc.UserDefault:getInstance():getIntegerForKey("SoundVolume",-1)
printInfo("==musicVolume:"..tostring(musicVolume))
printInfo("==soundVolume:"..tostring(soundVolume))
if musicVolume == -1 or soundVolume == -1 then
	musicVolume = 100
	soundVolume = 100
    cc.UserDefault:getInstance():setIntegerForKey("MusicVolume",musicVolume)
    cc.UserDefault:getInstance():setIntegerForKey("SoundVolume",soundVolume)
    cc.UserDefault:getInstance():flush()
end
audio.setMusicVolume(musicVolume / 100)
audio.setSoundsVolume(soundVolume / 100)

--设置音乐音量0-100
function SET_MUSIC_VOLUME( percent,saved )
	audio.setMusicVolume(percent / 100)
	if saved == false then
		return
	end
	cc.UserDefault:getInstance():setIntegerForKey("MusicVolume",percent)
	cc.UserDefault:getInstance():flush()
end
--0-100
function GET_MUSIC_VOLUME()
	return cc.UserDefault:getInstance():getIntegerForKey("MusicVolume",100)
end

--设置音效音量0-100
function SET_SOUND_VOLUME( percent )
	audio.setSoundsVolume(percent / 100)
	cc.UserDefault:getInstance():setIntegerForKey("SoundVolume",percent)
	cc.UserDefault:getInstance():flush()
end
--0-100
function GET_SOUND_VOLUME()
	return cc.UserDefault:getInstance():getIntegerForKey("SoundVolume",100)
end

--播放背景音乐
function PLAY_BACKGROUND_MUSIC()
	audio.playMusic("majia/sound/bg.mp3",true)
end

--停止背景音乐
function STOP_BACKGROUND_MUSIC()
	audio.stopMusic(false)
end

function CHANGE_BACKGROUND_MUSIC(filename)
	audio.playMusic(filename,true)
end

--播放音乐
function PLAY_MUSIC( filename, loop )
    if loop == nil then loop = true end
	audio.playMusic(filename,loop)
end

--停止音乐
function STOP_MUSIC()
	audio.stopMusic(true)
end

--播放音效
function PLAY_SOUND( filename, isLoop )
	audio.playSound(filename,isLoop)
end

--播放点击按钮音效
function PLAY_SOUND_CLICK()
	PLAY_SOUND("common/sound/click.mp3")
end

--停止音效
function STOP_ALL_SOUND()
	-- audio.stopAllEffects()
end
