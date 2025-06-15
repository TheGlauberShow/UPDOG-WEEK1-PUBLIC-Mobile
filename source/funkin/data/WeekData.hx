package funkin.data;

#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import haxe.Json;
import funkin.states.*;
import funkin.utils.CoolUtil;

using StringTools;

typedef WeekFile =
{
	// JSON variables
	var songs:Array<Dynamic>;
	var weekCharacters:Array<String>;
	var weekBackground:String;
	var weekBefore:String;
	var storyName:String;
	var weekName:String;
	var freeplayColor:Array<Int>;
	var startUnlocked:Bool;
	var hiddenUntilUnlocked:Bool;
	var hideStoryMode:Bool;
	var hideFreeplay:Bool;
	var difficulties:String;
	var beanDiffs:Array<Int>;
}

class WeekData
{
	public static var weeksLoaded:Map<String, WeekData> = new Map<String, WeekData>();
	public static var weeksList:Array<String> = [];

	public var folder:String = '';

	// JSON variables
	public var songs:Array<Dynamic>;
	public var weekCharacters:Array<String>;
	public var weekBackground:String;
	public var weekBefore:String;
	public var storyName:String;
	public var weekName:String;
	public var freeplayColor:Array<Int>;
	public var startUnlocked:Bool;
	public var hiddenUntilUnlocked:Bool;
	public var hideStoryMode:Bool;
	public var hideFreeplay:Bool;
	public var difficulties:String;
	public var beanDiffs:Array<Int>;

	public var fileName:String;

	public static function createWeekFile():WeekFile
	{
		var weekFile:WeekFile =
			{
				songs: [
					["Bopeebo", "dad", [146, 113, 253]],
					["Fresh", "dad", [146, 113, 253]],
					["Dad Battle", "dad", [146, 113, 253]]
				],
				weekCharacters: ['dad', 'bf', 'gf'],
				weekBackground: 'stage',
				weekBefore: 'tutorial',
				storyName: 'Your New Week',
				weekName: 'Custom Week',
				freeplayColor: [146, 113, 253],
				startUnlocked: true,
				beanDiffs: [3, 4],
				hiddenUntilUnlocked: false,
				hideStoryMode: false,
				hideFreeplay: false,
				difficulties: ''
			};
		return weekFile;
	}

	// HELP: Is there any way to convert a WeekFile to WeekData without having to put all variables there manually? I'm kind of a noob in haxe lmao
	public function new(weekFile:WeekFile, fileName:String)
	{
		songs = weekFile.songs;
		weekCharacters = weekFile.weekCharacters;
		weekBackground = weekFile.weekBackground;
		weekBefore = weekFile.weekBefore;
		storyName = weekFile.storyName;
		weekName = weekFile.weekName;
		freeplayColor = weekFile.freeplayColor;
		startUnlocked = weekFile.startUnlocked;
		hiddenUntilUnlocked = weekFile.hiddenUntilUnlocked;
		hideStoryMode = weekFile.hideStoryMode;
		hideFreeplay = weekFile.hideFreeplay;
		difficulties = weekFile.difficulties;
		beanDiffs = weekFile.beanDiffs;

		this.fileName = fileName;
	}

	public static function reloadWeekFiles(isStoryMode:Null<Bool> = false)
	{
		weeksList = [];
		weeksLoaded.clear();

		var weekListPaths = [
			"weeks/weekList.txt",
			"assets/weeks/weekList.txt",
			"assets/shared/weeks/weekList.txt",
			"content/weeks/weekList.txt"
		];

		var sexList:Array<String> = null;
		for (p in weekListPaths) {
			var assetPath = Paths.findAsset(p);
			if (assetPath != null && mobile.backend.AssetUtils.assetExists(assetPath)) {
				var txt = mobile.backend.AssetUtils.getText(assetPath);
				sexList = txt.split("\n").map(function(s) return s.trim()).filter(function(s) return s.length > 0);
				break;
			}
		}

		if (sexList == null) return;
		var weekFilePaths = [
			'weeks/$weekName.json',
			'assets/weeks/$weekName.json',
			'assets/shared/weeks/$weekName.json',
			'content/weeks/$weekName.json'
		];
		for (weekName in sexList) {
			if (!weeksLoaded.exists(weekName)) {
				for (p in weekFilePaths) {
				var path = p.replace("{NAME}", weekName);
				var assetPath = Paths.findAsset(path);
				if (assetPath != null && mobile.backend.AssetUtils.assetExists(assetPath)) {
					var week:WeekFile = getWeekFile(assetPath);
					var assetPath = Paths.findAsset(path);
				    if (assetPath != null && mobile.backend.AssetUtils.assetExists(assetPath)) {
						var week:WeekFile = getWeekFile(assetPath);
						if (week != null) {
							var weekFile:WeekData = new WeekData(week, weekName);
							if (weekFile != null
								&& (isStoryMode == null
									|| (isStoryMode && !weekFile.hideStoryMode)
									|| (!isStoryMode && !weekFile.hideFreeplay)))
							{
								weeksLoaded.set(weekName, weekFile);
								weeksList.push(weekName);
							}
							found = true;
							break;
						}
					}
				}
			}
		}
	}

	private static function addWeek(weekToCheck:String, path:String, directory:String, i:Int, originalLength:Int)
	{
		if (!weeksLoaded.exists(weekToCheck))
		{
			var week:WeekFile = getWeekFile(path);
			if (week != null)
			{
				var weekFile:WeekData = new WeekData(week, weekToCheck);
				if (i >= originalLength)
				{
					#if MODS_ALLOWED
					weekFile.folder = directory.substring(Paths.mods().length, directory.length - 1);
					#end
				}
				if ((PlayState.isStoryMode && !weekFile.hideStoryMode) || (!PlayState.isStoryMode && !weekFile.hideFreeplay))
				{
					weeksLoaded.set(weekToCheck, weekFile);
					weeksList.push(weekToCheck);
				}
			}
		}
	}

	private static function getWeekFile(path:String):WeekFile
	{
		var rawJson:String = null;

		var assetPath = Paths.findAsset(path);
		if (assetPath != null && mobile.backend.AssetUtils.assetExists(assetPath)) {
			rawJson = mobile.backend.AssetUtils.getAssetContent(assetPath);
		}

		if (rawJson != null && rawJson.length > 0)
		{
			return cast haxe.Json.parse(rawJson); // Json.parse(rawJson)
		}
		return null;
	}

	//   FUNCTIONS YOU WILL PROBABLY NEVER NEED TO USE
	// To use on PlayState.hx or Highscore stuff
	public static function getWeekFileName():String
	{
		return weeksList[PlayState.storyWeek];
	}

	// Used on LoadingState, nothing really too relevant
	public static function getCurrentWeek():WeekData
	{
		return weeksLoaded.get(weeksList[PlayState.storyWeek]);
	}

	public static function setDirectoryFromWeek(?data:WeekData = null)
	{
		Paths.currentModDirectory = '';
		if (data != null && data.folder != null && data.folder.length > 0)
		{
			Paths.currentModDirectory = data.folder;
		}
	}

	public static function loadTheFirstEnabledMod()
	{
		Paths.currentModDirectory = '';

		#if MODS_ALLOWED
		if (mobile.backend.AssetUtils.assetExists("modsList.txt"))
		{
			var list:Array<String> = CoolUtil.listFromString(mobile.backend.AssetUtils.getText("modsList.txt"));
			var foundTheTop = false;
			for (i in list)
			{
				var dat = i.split("|");
				if (dat[1] == "1" && !foundTheTop)
				{
					foundTheTop = true;
					Paths.currentModDirectory = dat[0];
				}
			}
		}
		#end
	}
}
