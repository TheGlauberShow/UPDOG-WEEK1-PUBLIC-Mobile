package funkin.data;

import openfl.Assets;
import funkin.data.Section.SwagSection;

import haxe.Json;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	
	var keys:Int;
	var lanes:Int;
	
	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;
	
	var arrowSkin:String;
	var splashSkin:String;
	var validScore:Bool;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var events:Array<Dynamic>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var arrowSkin:String = 'default';
	public var splashSkin:String;
	public var speed:Float = 1;
	public var stage:String;
	
	public var keys:Int = 4;
	public var lanes:Int = 2;
	
	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = 'gf';
	
	public static function onLoadJson(songJson:Dynamic) // Convert old charts to newest format
	{
		if (songJson.gfVersion == null)
		{
			songJson.gfVersion = songJson.player3;
			songJson.player3 = null;
		}
		
		if (songJson.keys == null) songJson.keys = 4;
		if (songJson.lanes == null) songJson.lanes = 2;
		
		if (songJson.events == null)
		{
			songJson.events = [];
			for (secNum in 0...songJson.notes.length)
			{
				var sec:SwagSection = songJson.notes[secNum];
				
				var i:Int = 0;
				var notes:Array<Dynamic> = sec.sectionNotes;
				var len:Int = notes.length;
				while (i < len)
				{
					var note:Array<Dynamic> = notes[i];
					if (note[1] < 0)
					{
						songJson.events.push([note[0], [[note[2], note[3], note[4]]]]);
						notes.remove(note);
						len = notes.length;
					}
					else i++;
				}
			}
		}
	}
	
	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}
	
	public static function loadFromJson(jsonInput:String, ?folder:String, ?mod:Bool = false):SwagSong
	{
		var rawJson = null;

		var formattedFolder:String = Paths.formatToSongPath(folder);
		var formattedSong:String = Paths.formatToSongPath(jsonInput);

		var assetPath = Paths.findAsset('songs/' + formattedFolder + '/' + formattedSong + '.json');
		if (assetPath != null && mobile.backend.AssetUtils.assetExists(assetPath)) {
			rawJson = mobile.backend.AssetUtils.getAssetContent(assetPath);
			if (rawJson != null) rawJson = rawJson.trim();
		}

		if (rawJson == null) {
			try {
				rawJson = openfl.Assets.getText('assets/songs/$formattedFolder/$formattedSong.json');
				if (rawJson != null) // try in content folder too
					rawJson = openfl.Assets.getText('content/songs/$formattedFolder/$formattedSong.json');
				if (rawJson != null)  rawJson = rawJson.trim();
			} catch (e) {
				rawJson = openfl.Assets.getText(Paths.json('songs/' + formattedFolder + '/' + formattedSong));
				if (rawJson != null) rawJson = rawJson.trim();
			}
		}

		while (rawJson != null && !rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
		}

		var songJson:Dynamic = parseJSONshit(rawJson);
		if (jsonInput != 'events') StageData.loadDirectory(songJson);
		onLoadJson(songJson);
		return songJson;
	}
	
	public static function parseJSONshit(rawJson:String):SwagSong
	{
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}
