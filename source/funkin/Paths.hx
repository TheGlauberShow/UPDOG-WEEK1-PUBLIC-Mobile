package funkin;

import openfl.system.System;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import haxe.Json;
import openfl.display.BitmapData;
import openfl.media.Sound;

import mobile.backend.AssetUtils;

// Error Screen Debug
import mobile.scripting.NativeAPI;

@:access(openfl.display.BitmapData)
class Paths
{
    public static var currentModDirectory:String = '';

	/**
	 * Primary asset directory
	 */
	inline public static final CORE_DIRECTORY = #if ASSET_REDIRECT #if macos '../../../../../../../assets' #else '../../../../assets' #end #else 'assets' #end;
	
	/**
	 * Mod directory
	 */
	inline public static final MODS_DIRECTORY = #if ASSET_REDIRECT #if macos '../../../../../../../content' #else '../../../../content' #end #else 'content' #end;
	
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";
	
	//#if MODS_ALLOWED
	public static var ignoreModFolders:Array<String> = [
		'characters',
		'custom_events',
		'custom_notetypes',
		'data',
		'songs',
		'music',
		'sounds',
		'shaders',
		'noteskins',
		'videos',
		'images',
		'stages',
		'weeks',
		'fonts',
		'scripts',
		'achievements'
	];
	//#end
	
	public static function excludeAsset(key:String)
	{
		if (!dumpExclusions.contains(key)) dumpExclusions.push(key);
	}
	
	public static var dumpExclusions:Array<String> = [
		'$CORE_DIRECTORY/music/freakyMenu.$SOUND_EXT',
		'$CORE_DIRECTORY/shared/music/breakfast.$SOUND_EXT',
		'$CORE_DIRECTORY/shared/music/tea-time.$SOUND_EXT',
	];
	
	public static function clearUnusedMemory()
	{
		// clear non local assets in the tracked assets list
		for (key in currentTrackedAssets.keys())
		{
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key))
			{
				disposeGraphic(currentTrackedAssets.get(key));
				currentTrackedAssets.remove(key);
			}
		}
		// run the garbage collector for good measure lmfao
		System.gc();
		#if cpp
		cpp.vm.Gc.compact();
		#end
	}
	
	// define the locally tracked assets
	public static var localTrackedAssets:Array<String> = [];
	
	public static function clearStoredMemory()
	{
		// clear anything not in the tracked assets list
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			if (!currentTrackedAssets.exists(key)) disposeGraphic(FlxG.bitmap.get(key));
		}
		
		// clear all sounds that are cached
		for (key in currentTrackedSounds.keys())
		{
			if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && key != null)
			{
				// trace('test: ' + dumpExclusions, key);
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
		openfl.Assets.cache.clear("songs");
	}
	
	/**
	 * Disposes of a flxgraphic
	 * 
	 * frees its gpu texture as well.
	 * @param graphic 
	 */
	public static function disposeGraphic(graphic:FlxGraphic)
	{
		if (graphic != null && graphic.bitmap != null && graphic.bitmap.__texture != null) graphic.bitmap.__texture.dispose();
		FlxG.bitmap.remove(graphic);
	}

	static public var currentLevel:String;
	
	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}
	
	public static function getPath(file:String, ?type:AssetType = TEXT, ?library:Null<String> = null)
	{
		if (library != null) return getLibraryPath(file, library);
		
		if (currentLevel != null)
		{
			var levelPath:String = '';
			if (currentLevel != 'shared')
			{
				levelPath = getLibraryPathForce(file, currentLevel);
				if (OpenFlAssets.exists(levelPath, type)) return levelPath;
			}
			
			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type)) return levelPath;
		}
		
		// #if ASSET_REDIRECT
		// openfl check
		final sharedFL = getLibraryPathForce(file, "shared");
		if (OpenFlAssets.exists(strip(sharedFL), type)) return strip(sharedFL);
		// #end
		
		return getSharedPath(file);
	}
	
	static public function getLibraryPath(file:String, library = "shared")
	{
		return if (library == "shared") getSharedPath(file); else getLibraryPathForce(file, library);
	}
	
	static function getLibraryPathForce(file:String, library:String)
	{
		var returnPath = '$library:assets/$library/$file';
		return returnPath;
	}
	
	public static function getSharedPath(file:String = '')
	{
		return '$CORE_DIRECTORY/shared/$file';
	}
	
	public static function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}
	
	public static function txt(key:String, ?library:String)
    {
        var path = findAsset('data/$key.txt');
        if (path != null)
            return path;
        return getPath('data/$key.txt', TEXT, library);
    }

    public static function xml(key:String, ?library:String)
    {
        var path = findAsset('data/$key.xml');
        if (path != null)
            return path;
        return getPath('data/$key.xml', TEXT, library);
    }
	
	public static function json(key:String, ?library:String)
    {
        var path = findAsset('songs/$key.json');
        if (path != null)
            return path;
        return getPath('songs/$key.json', TEXT, library);
    }
	
	public static function noteskin(key:String, ?library:String)
    {
        var path = findAsset('noteskins/$key.json');
        if (path != null)
            return path;
        return getPath('noteskins/$key.json', TEXT, library);
    }

    public static function modsNoteskin(key:String)
	{
        var path = findAsset('noteskins/$key.json');
        if (path != null)
            return path;
		return getPath('noteskins/$key.json'); // modFolders
	}

    public static function shaderFragment(key:String, ?library:String)
    {
        var path = findAsset('shaders/$key.frag');
        if (path != null)
            return path;
        return getPath('shaders/$key.frag', TEXT, library);
    }

    public static function shaderVertex(key:String, ?library:String)
    {
        var path = findAsset('shaders/$key.vert');
        if (path != null)
            return path;
        return getPath('shaders/$key.vert', TEXT, library);
    }

    public static function lua(key:String, ?library:String)
    {
        var path = findAsset('$key.lua');
        if (path != null)
            return path;
        return getPath('$key.lua', TEXT, library);
    }

	public static function getContent(asset:String):Null<String>
	{
		if (Assets.exists(asset)) return Assets.getText(asset);
		
		trace('oh no its returning null NOOOO ($asset)');
		return null;
	}

	public static function video(key:String)
	{
            try {
                var path = "videos/" + key + ".mp4";
                return findAsset(path);
            } catch (e:Dynamic) {
                NativeAPI.showMessageBox("Paths Error", "The video \"" + key + "\" could not be found. Please check the file path or ensure the video exists in the assets directory.\n" + Std.string(e));
                return '$CORE_DIRECTORY/videos'; // or other(can be null)
            }
	}
	
	public static function modTextureAtlas(key:String)
	{
		try {
	    	if (currentLevel != null && currentLevel != 'shared')
	    	{
	    		var levelPath:String = getLibraryPathForce('images/$key', currentLevel);
	    		if (mobile.backend.AssetUtils.assetExists(levelPath)) return levelPath;
	    		else if (OpenFlAssets.exists(levelPath, AssetType.BINARY)) return levelPath;
	    	}

	    	var finalPath = getPath('images/$key', AssetType.BINARY);
	    	if (mobile.backend.AssetUtils.assetExists(finalPath)) return finalPath;
	    	else if (OpenFlAssets.exists(finalPath, AssetType.BINARY)) return finalPath;

	    	throw "Texture atlas not found: $key"; // forçar se nao for achado kkk
	    } catch (e:Dynamic) {
            trace('Error on load texture atlas: $key -> $e');
            NativeAPI.showMessageBox("Path Error", "The Mod texture \"" + key + "\" could not be found. Please check if the .atlas file is present in the assets or mods folder.\n" + Std.string(e));
            return null;
        }
	}
	
	public static function textureAtlas(key:String, ?library:String)
	{
            var finalPath = getPath('images/$key.atlas', AssetType.BINARY, library);
            try {
	            if (mobile.backend.AssetUtils.assetExists(finalPath))
	            	return finalPath;
	            else if (OpenFlAssets.exists(finalPath, AssetType.BINARY))
	            	return finalPath;

                return null;
            } catch (e:Dynamic) {
	            trace('Error: atlas not found for "$key" in any path ($finalPath)');
	            NativeAPI.showMessageBox("Path Error", "The texture atlas \"" + key + "\" could not be found. Please check if the \".atlas\" file is present in the mods or assets folder.");
                return null;
            }
	}
	
	    public static function sound(key:String, ?library:String):Sound
        {
            var path = "sounds/" + key + ".ogg";
            return Sound.fromFile(findAsset(path)); // can be String
        }
	
	public static function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}
	
	public static function music(key:String, ?library:String):Sound
	{
		var file:Sound = returnSound('music', key, library);
		return file;
	}
	
	public static function voices(song:String, ?postFix:String):Null<openfl.media.Sound>
    {
        var songPath = formatToSongPath(song);
        var baseName = 'Voices';
        if (postFix != null) baseName += '-$postFix';
        var targetName = baseName + '.ogg';

        var oggFiles = listOggFilesInSongs();

        for (filePath in oggFiles)
        {
            if (filePath.indexOf(songPath) != -1 && filePath.endsWith(targetName))
            {
                if (!currentTrackedSounds.exists(filePath))
                {
                    currentTrackedSounds.set(filePath, Sound.fromFile(filePath));
                }
                localTrackedAssets.push(filePath);
                return currentTrackedSounds.get(filePath);
            }
        }

        if (postFix != null)
        {
            var fallbackName = 'Voices.ogg';
            for (filePath in oggFiles)
            {
                if (filePath.indexOf(songPath) != -1 && filePath.endsWith(fallbackName))
                {
                    if (!currentTrackedSounds.exists(filePath))
                    {
                        currentTrackedSounds.set(filePath, Sound.fromFile(filePath));
                    }
                    localTrackedAssets.push(filePath);
                    return currentTrackedSounds.get(filePath);
                }
            }
        }

        var soundKey = '$songPath/Voices';
        if (postFix != null) soundKey += '-$postFix';
        return returnSound(null, soundKey, 'songs');
    }

	public static function inst(song:String):Null<openfl.media.Sound>
    {
		// I'm learning :)
        var songPath = formatToSongPath(song); // ex: "mymusic"
        var targetName = 'Inst.ogg';

        var oggFiles = listOggFilesInSongs();

        for (filePath in oggFiles)
        {
            if (filePath.indexOf(songPath) != -1 && filePath.endsWith(targetName))
            {
                if (!currentTrackedSounds.exists(filePath))
                {
                    currentTrackedSounds.set(filePath, Sound.fromFile(filePath));
                }
                localTrackedAssets.push(filePath);
                return currentTrackedSounds.get(filePath);
            }
        }

        var soundKey = '$songPath/Inst';
        return returnSound(null, soundKey, 'songs');
    }

	public static function listOggFilesInSongs():Array<String> {
        var assetsSongs = [for (path in mobile.backend.AssetUtils.listAssets("assets/songs", null)) if (path.endsWith(".ogg")) path];
        var contentSongs = [for (path in mobile.backend.AssetUtils.listAssets("content/songs", null)) if (path.endsWith(".ogg")) path];
        return assetsSongs.concat(contentSongs);
    }

    public static function modsShaderFragment(key:String, ?library:String):Null<String>
    {
        return findAsset('shaders/$key.frag');
    }

    public static function modsShaderVertex(key:String, ?library:String):Null<String>
    {
        return findAsset('shaders/$key.vert');
    }

    public static function image(key:String, ?library:String):FlxGraphic
    {
        var path = findAsset('images/$key.png');
        if (path != null) {
            var bitmap = BitmapData.fromFile(path);
            return FlxGraphic.fromBitmapData(bitmap, false, path);
        }
        return returnGraphic(key, library); // default fallback
    }

    public static function findAsset(relPath:String):Null<String>
    {
        #if mobile
        var prefixes = [
            "assets/",
            "assets/shared/",
            "content/"
        ];

        for (prefix in prefixes)
        {
            var path = prefix + relPath;
            if (AssetUtils.assetExists(path) || OpenFlAssets.exists(path))
                return path;
        }
        trace('Asset not found: $relPath');
        NativeAPI.showMessageBox("Path Error", "The asset \"" + relPath + "\" could not be found. Please check the file path or ensure the asset exists in the assets or mods folder.");
        #else
        var paths = [
            'assets/' + relPath,
            'assets/shared/' + relPath,
            'content/' + relPath
        ];

        for (path in paths)
        {
            /*#if sys
            if (sys.FileSystem.exists(path))
                return path;
            #end*/
            if (mobile.backend.AssetUtils.assetExists(path))
                return path;
            else if (OpenFlAssets.exists(path)) // fallback for assets embedded
                return path;
        }
        #end

        trace('Asset not found: $relPath');
        NativeAPI.showMessageBox("Path Error", "The asset \"" + relPath + "\" could not be found. Please check the file path or ensure the asset exists in the assets or mods folder.");
        return null;
    }

    public static function tryPaths(base:String, paths:Array<String>):Null<String>
    {
		// example call: var shaderPath = tryPaths('shaders/' + key + '.frag', ['assets/', 'assets/shared/', 'content/']);
        for (p in paths)
        {
            var full = p + base;
            if (#if sys sys.FileSystem.exists(full) || #end mobile.backend.AssetUtils.assetExists(full) || OpenFlAssets.exists(full))
                return full;
        }
        return null;
    }
	
	public static function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		if (OpenFlAssets.exists(getPath(key, TEXT)))
		{
			return OpenFlAssets.getText(getPath(key, TEXT));
		}
		else if (Assets.exists(getPath(key, TEXT)))
		{
			return Assets.getText(getPath(key, TEXT));
		}
		else if (mobile.backend.AssetUtils.assetExists(getPath(key)))
		{
			return mobile.backend.AssetUtils.getText(getPath(key));
		}

		trace('Text file ($key) not found');
		NativeAPI.showMessageBox("Path Error", "The text file \"" + key + "\" could not be found. Please check the file path or ensure the text file exists in the assets or mods folder.");
		return '';
	}

    public static function font(key:String):Null<String>
    {
        var assetPath:String = findAsset('fonts/$key.ttf');
        if (assetPath != null) return assetPath;

        trace('Font file ($key) not found');
        NativeAPI.showMessageBox("Path Error", "The font file \"" + key + "\" could not be found. Please check the file path or ensure the font file exists in the assets or mods folder.");
        return '$CORE_DIRECTORY/fonts/$key';
    }

    public static function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
    {
        if (OpenFlAssets.exists(getPath(key, type)))
        {
            return true;
        }
        else if (Assets.exists(getPath(key, type)))
        {
            return true;
        }
        else if (mobile.backend.AssetUtils.assetExists(getPath(key, type)))
        {
            return true;
        }
        return false;
    }

    public static function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames
    {
        // Search PNG and TXT in mods, assets/shared and assets
        var imagePath:String = findAsset('images/$key.png');
        var xmlPath:String = findAsset('images/$key.xml');

        var imageLoaded:FlxGraphic = null;
        if (imagePath != null) {
            var bitmap = BitmapData.fromFile(imagePath);
            imageLoaded = FlxGraphic.fromBitmapData(bitmap, false, imagePath);
        } else {
            imageLoaded = image(key, library); // fallback
        }

        var xmlContent:String = null;
        if (xmlPath != null) {
            xmlContent = getContent(xmlPath);
        } else {
            xmlContent = file('images/$key.xml', library);
        }

        return FlxAtlasFrames.fromSparrow(imageLoaded, xmlContent);
    }

	public static function getPackerAtlas(key:String, ?library:String):FlxAtlasFrames
    {
        // Search PNG and TXT in mods, assets/shared and assets
        var imagePath:String = findAsset('images/$key.png');
        var txtPath:String = findAsset('images/$key.txt');

        var imageLoaded:FlxGraphic = null;
        if (imagePath != null) {
            var bitmap = BitmapData.fromFile(imagePath);
            imageLoaded = FlxGraphic.fromBitmapData(bitmap, false, imagePath);
        } else {
            imageLoaded = image(key, library); // fallback
        }

        var txtContent:String = null;
        if (txtPath != null) {
            txtContent = getContent(txtPath);
        } else {
            txtContent = file('images/$key.txt', library);
        }

        return FlxAtlasFrames.fromSpriteSheetPacker(imageLoaded, txtContent);
    }

	public static function formatToSongPath(path:String)//inline
	{
		return path.toLowerCase().replace(' ', '-'); // example: formatToSongPath("Ugh Oh") make this way: assets/songs/ugh-oh/Inst.ogg, Voices.ogg, or others
	}
	
	// completely rewritten asset loading? fuck!
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	
	public static function returnGraphic(key:String, ?library:String, ?allowGPU:Bool = true)
    {
        var bitmap:BitmapData = null;
        var file:String = null;
        // fallback direto para assets
        file = getPath('images/$key.png', IMAGE, library); // getPath or findAsset

        if (bitmap == null)
        {
            var assetPath:String = findAsset('images/$key.png');
            if (assetPath != null)
            {
                file = assetPath;
                bitmap = OpenFlAssets.exists(file, IMAGE) 
                         ? OpenFlAssets.getBitmapData(file)
                         : BitmapData.fromFile(file);
            }
        }
        if (bitmap != null)
        {
            var retVal = cacheBitmap(file, bitmap, allowGPU);
            if (retVal != null) return retVal;
        }

        trace('oh no its returning null NOOOO ($file)');
		NativeAPI.showMessageBox("Path Error", "The image \"" + key + "\" could not be found. Please check the file path or ensure the image exists in the assets or mods folder.");
        return null;
    }

    public static function cacheBitmap(file:String, ?bitmap:BitmapData = null, ?allowGPU:Bool = true)
    {
        if (bitmap == null)
        {
            if (bitmap == null && OpenFlAssets.exists(file, IMAGE))
                bitmap = OpenFlAssets.getBitmapData(file);

            if (bitmap == null) return null;
        }
        localTrackedAssets.push(file);
        if (allowGPU && ClientPrefs.gpuCaching)
        {
            var texture = FlxG.stage.context3D.createRectangleTexture(
                bitmap.width, bitmap.height, BGRA, true
            );
            texture.uploadFromBitmapData(bitmap);
            bitmap.image.data = null;
            bitmap.dispose();
            bitmap.disposeImage();
            bitmap = BitmapData.fromTexture(texture);
        }
        var newGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
        newGraphic.persist = true;
        newGraphic.destroyOnNoUse = false;
        currentTrackedAssets.set(file, newGraphic);
        return newGraphic;
    }
	
	public static var currentTrackedSounds:Map<String, Sound> = [];
	
	public static function returnSound(path:Null<String>, key:String, ?library:String):Null<Sound>
    {
        var soundRelPath:String = (path != null ? '$path/' : '') + '$key.$SOUND_EXT';
        var fullPath:String = findAsset(soundRelPath);
        if (fullPath != null)
        {
            if (!currentTrackedSounds.exists(fullPath))
            {
                currentTrackedSounds.set(fullPath, Sound.fromFile(fullPath));
            }
            localTrackedAssets.push(fullPath);
            return currentTrackedSounds.get(fullPath);
        }
        var embeddedKey:String = (path != null ? '$path/' : '') + key;
        var openflKey:String = (path == 'songs') ? 'songs:' + getPath('$embeddedKey.$SOUND_EXT', SOUND, library) : getPath('$embeddedKey.$SOUND_EXT', SOUND, library);
        if (OpenFlAssets.exists(openflKey, SOUND))
        {
            if (!currentTrackedSounds.exists(openflKey))
            {
                currentTrackedSounds.set(openflKey, OpenFlAssets.getSound(openflKey));
            }
            localTrackedAssets.push(openflKey);
            return currentTrackedSounds.get(openflKey);
        }

        trace('returnSound: not possible to find "$key" in any valid location.');
        NativeAPI.showMessageBox("Path Error", "The sound \"" + key + "\" could not be found. Please check the file path or ensure the sound file exists in the assets or mods folder.");
        return null;
    }
	//inline 
	public static function strip(path:String) return path.indexOf(':') != -1 ? path.substr(path.indexOf(':') + 1, path.length) : path;
	
	// in project.xml the #if MODS_ALLOWED is just for desktop
    inline static public function mods(key:String = ""):String
    {
        return "$MODS_DIRECTORY/" + key;
    }

    inline static public function modsFont(key:String):String
    {
        // two internal types
        var fontPath = getPath('fonts/$key.ttf', AssetType.FONT);
        return fontPath;
        // return "$MODS_DIRECTORY/fonts/" + key;
    }

    inline static public function modsJson(key:String):String
    {
        var jsonPath = "data/" + key + ".json";
        return findAsset(jsonPath);
    }

    inline static public function modsVideo(key:String):String
    {
        var videoPath = "videos/" + key + "." + VIDEO_EXT;
        return findAsset(videoPath);
    }

    inline static public function modsSounds(path:String, key:String):String
    {
        var soundPath = "sounds/" + key + "." + SOUND_EXT;
        return findAsset(soundPath);
    }

    inline static public function modsImages(key:String):String
    {
        var imagesPath = "images/" + key + ".png";
        return findAsset(imagesPath);
    }

    inline static public function modsXml(key:String):String
    {
        var xmlPath = "images/" + key + ".xml";
        return findAsset(xmlPath);
    }

    inline static public function modsTxt(key:String):String
    {
        var txtPath = "images/" + key + ".txt";
        return findAsset(txtPath);
    }

    // Internal Version -- @TheGlauberShow
    public static function modFolders(key:String, ?global:Bool = true):String
    {
        return "$MODS_DIRECTORY/" + key;
    }

    public static var globalMods:Array<String> = [];

    public static function getGlobalMods():Array<String>
    {
        return globalMods;
    }

    public static function pushGlobalMods():Array<String>
    {
        globalMods = [];

        if (mobile.backend.AssetUtils.assetExists("modsList.txt"))
        {
            var lines:Array<String> = CoolUtil.listFromString(mobile.backend.AssetUtils.getAssetContent("modsList.txt"));
            for (line in lines)
            {
                var dat = line.split("|");
                if (dat[1] == "1")
                {
                    var folder = dat[0];
                    var packPath = Paths.mods(folder + "/pack.json");
                    if (mobile.backend.AssetUtils.assetExists(packPath))
                    {
                        try
                        {
                            var raw:String = mobile.backend.AssetUtils.getText(packPath);
                            if (raw != null && raw.length > 0)
                            {
                                var info:Dynamic = Json.parse(raw);
                                var runsGlobally:Bool = Reflect.getProperty(info, "runsGlobally");
                                if (runsGlobally)
                                    globalMods.push(folder);
                            }
                        }
                        catch (e:Dynamic)
                        {
                            NativeAPI.showMessageBox("Path Error", "Failed to parse pack.json for mod \"" + folder + "\".\n" + Std.string(e));
                        }
                    }
                }
            }
        }

        return globalMods;
    }

    public static function getModDirectories():Array<String>
    {
        var listContent = [
            'assets/',
            'assets/shared',
            'content/'
        ];
        var list:Array<String> = [];
        for (folder in listContent)
        {
            var path = haxe.io.Path.join([folder]);
            if (!ignoreModFolders.contains(folder) && !list.contains(folder))
                list.push(folder);
        }

        return listContent;
    }
}
