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
	public static function strip(path:String) return path.indexOf(':') != -1 ? path.substr(path.indexOf(':') + 1, path.length) : path;
    public static var currentModDirectory:String = '';
    public static var currentTrackedSounds:Map<String, Sound> = []; 
    public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
    static public var currentLevel:String;
    public static var localTrackedAssets:Array<String> = [];

	inline public static final CORE_DIRECTORY = 'assets';
    inline public static final MODS_DIRECTORY = 'content';
    inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
    inline public static var VIDEO_EXT = "mp4";

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

	public static function disposeGraphic(graphic:FlxGraphic)
	{
		if (graphic != null && graphic.bitmap != null && graphic.bitmap.__texture != null) graphic.bitmap.__texture.dispose();
		FlxG.bitmap.remove(graphic);
	}

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

		final sharedFL = getLibraryPathForce(file, "shared");
		if (OpenFlAssets.exists(strip(sharedFL), type)) return strip(sharedFL);
		
		return getSharedPath(file); // fallback
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

    // --- ASSET FILE TYPES LOADER ---

	public static function txt(key:String):Null<String> {
        return findAsset('data/$key.txt');
    }

    public static function xml(key:String):Null<String> {
        return findAsset('data/$key.xml');
    }

    public static function json(key:String):Null<String> {
        // Always search in songs/ for charts
        return findAsset('songs/$key.json');
    }

    public static function noteskin(key:String):Null<String> {
        return findAsset('noteskins/$key.json');
    }

    public static function modsNoteskin(key:String):Null<String> {
        return findAsset('noteskins/$key.json');
    }

    public static function shaderFragment(key:String):Null<String> {
        return findAnyAsset('shaders/' + key, ['.frag']);
    }

    public static function shaderVertex(key:String):Null<String> {
        return findAnyAsset('shaders/' + key, ['.vert']);
    }

    public static function lua(key:String):Null<String> {
        return findAnyAsset(key, ['.lua']);
    }

	public static function video(key:String):Null<String> {
        return findAnyAsset('videos/' + key, ['.mp4']);
    }

    public static function font(key:String):Null<String> {
        var assetPath:String = findAsset('fonts/$key.ttf');
        if (assetPath != null) return assetPath;

        trace('Font file ($key) not found');
        //NativeAPI.showMessageBox("Path Error", "The font file \"" + key + "\" could not be found. Please check the file path or ensure the font file exists in the assets or mods folder.");
        return '$CORE_DIRECTORY/fonts/$key'; // fallback
    }

    // --- SONGS AND MUSICS LOADERS ---
	
    public static function sound(key:String):Sound {
        var path = findAnyAsset('sounds/' + key, ['.' + SOUND_EXT]);
        return path != null ? Sound.fromFile(path) : null;
    }

    public static function soundRandom(key:String, min:Int, max:Int):Sound {
        return sound(key + FlxG.random.int(min, max));
    }

    public static function music(key:String):Sound {
        var path = findAnyAsset('music/' + key, ['.' + SOUND_EXT]);
        return path != null ? Sound.fromFile(path) : null;
    }
	
	public static function voices(song:String, ?postFix:String):Null<openfl.media.Sound> {
        var songPath = formatToSongPath(song);
        var baseName = 'Voices';
        if (postFix != null) baseName += '-$postFix';
        var targetName = baseName + '.' + SOUND_EXT;
        var oggFiles = listOggFilesInSongs();
        for (filePath in oggFiles) {
            if (filePath.indexOf(songPath) != -1 && filePath.endsWith(targetName)) {
                if (!currentTrackedSounds.exists(filePath))
                    currentTrackedSounds.set(filePath, Sound.fromFile(filePath));
                localTrackedAssets.push(filePath);
                return currentTrackedSounds.get(filePath);
            }
        }
        if (postFix != null) {
            var fallbackName = 'Voices.' + SOUND_EXT;
            for (filePath in oggFiles) {
                if (filePath.indexOf(songPath) != -1 && filePath.endsWith(fallbackName)) {
                    if (!currentTrackedSounds.exists(filePath))
                        currentTrackedSounds.set(filePath, Sound.fromFile(filePath));
                    localTrackedAssets.push(filePath);
                    return currentTrackedSounds.get(filePath);
                }
            }
        }
        return null;
    }

    public static function inst(song:String):Null<openfl.media.Sound> {
        var songPath = formatToSongPath(song);
        var targetName = 'Inst.' + SOUND_EXT;
        var oggFiles = listOggFilesInSongs();
        for (filePath in oggFiles) {
            if (filePath.indexOf(songPath) != -1 && filePath.endsWith(targetName)) {
                if (!currentTrackedSounds.exists(filePath))
                    currentTrackedSounds.set(filePath, Sound.fromFile(filePath));
                localTrackedAssets.push(filePath);
                return currentTrackedSounds.get(filePath);
            }
        }
        return null;
    }

    public static function listOggFilesInSongs():Array<String> {
        var assetsSongs = [for (path in mobile.backend.AssetUtils.listAssetsFromPrefix("assets/songs")) if (path.endsWith("." + SOUND_EXT)) path];
        var contentSongs = [for (path in mobile.backend.AssetUtils.listAssetsFromPrefix("content/songs")) if (path.endsWith("." + SOUND_EXT)) path];
        return assetsSongs.concat(contentSongs);
    }

    public static function returnSound(path:Null<String>, key:String, ?library:String):Null<Sound> {
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
        //NativeAPI.showMessageBox("Path Error", "The sound \"" + key + "\" could not be found. Please check the file path or ensure the sound file exists in the assets or mods folder.");
        return null;
    }

    // --- ATLAS AND IMAGES LOADERS ---

    public static function image(key:String):FlxGraphic {
        var path = findAnyAsset('images/' + key, ['.png']);
        if (path != null) {
            var bitmap = BitmapData.fromFile(path);
            return FlxGraphic.fromBitmapData(bitmap, false, path);
        }
        return null;
    }

    public static function textureAtlas(key:String, ?library:String):Null<String>
    {
        var searchFolders = [
            "assets/shared/images/",
            "content/images/"
        ];
        var fileName = key + ".atlas";
        for (folder in searchFolders)
        {
            // list of all files inside in the folder(and subfolders)
            var files = mobile.backend.AssetUtils.listAssetsFromPrefix(folder);
            for (f in files)
            {
                // Go search if a file end with the desejed extension (can the file stay in subfolders)
                if (f.endsWith("/" + fileName) || f.endsWith("\\" + fileName) || f.endsWith(fileName))
                    return f;
            }
        }
        return null;

        // ---- OTHER WAY ---- \\

        // var finalPath = getPath('images/$key.atlas', AssetType.BINARY, library);
        /*try {
            if (mobile.backend.AssetUtils.assetExists(finalPath))
                return finalPath;
            else if (OpenFlAssets.exists(finalPath, AssetType.BINARY))
                return finalPath;
            return null;
        } catch (e:Dynamic) {
            trace('Error: atlas not found for "$key" in any path ($finalPath)');
            //NativeAPI.showMessageBox("Path Error", "The texture atlas \"" + key + "\" could not be found. Please check if the \".atlas\" file is present in the mods or assets folder.");
            return null;
        }*/
    }

    public static function getSparrowAtlas(key:String):FlxAtlasFrames {
        var imagePath = findAnyAsset('images/' + key, ['.png']);
        var xmlPath = findAnyAsset('images/' + key, ['.xml']);
        if (imagePath != null && xmlPath != null) {
            var bitmap = BitmapData.fromFile(imagePath);
            var xmlContent = mobile.backend.AssetUtils.getAssetContent(xmlPath);
            return FlxAtlasFrames.fromSparrow(FlxGraphic.fromBitmapData(bitmap, false, imagePath), xmlContent);
        }
        return null;
    }

	public static function getPackerAtlas(key:String):FlxAtlasFrames {
        var imagePath = findAnyAsset('images/' + key, ['.png']);
        var txtPath = findAnyAsset('images/' + key, ['.txt']);
        if (imagePath != null && txtPath != null) {
            var bitmap = BitmapData.fromFile(imagePath);
            var txtContent = mobile.backend.AssetUtils.getAssetContent(txtPath);
            return FlxAtlasFrames.fromSpriteSheetPacker(FlxGraphic.fromBitmapData(bitmap, false, imagePath), txtContent);
        }
        return null;
    }

    public static function findImageAsset(name:String):Null<String> {
        // Try search .png images in all folders
        return findAnyAsset('images/' + name, ['.png']);
    }

    public static function findAtlasAsset(name:String):Null<String> {
        // Try search .xml or .json for atlas in all folders
        var xml = findAnyAsset('images/' + name, ['.xml']);
        if (xml != null) return xml;
        return findAnyAsset('images/' + name, ['.json']);
    }

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
		//NativeAPI.showMessageBox("Path Error", "The image \"" + key + "\" could not be found. Please check the file path or ensure the image exists in the assets or mods folder.");
        return null;
    }

    // --- UNIVERSAL ASSET SEARCH HELPERS ---

    // Use findAsset for single extension, findAnyAsset for multiple
    public static function findAsset(relPath:String):Null<String> {
        var prefixes = ["assets/", "assets/shared/", "content/"];
        for (prefix in prefixes) {
            var path = prefix + relPath;
            if (AssetUtils.assetExists(path) || OpenFlAssets.exists(path))
                return path;
        }
        return null;
    }

    public static function findAnyAsset(relPath:String, exts:Array<String>):Null<String> {
        var prefixes = [
            "assets/", "assets/shared/", "content/",
            "assets/fonts/", "assets/shared/fonts/", "content/fonts/",
            "assets/shared/images/", "content/images/",
            "assets/shared/images/characters/", "content/images/characters/",
            "assets/shared/images/hud/", "content/images/hud/",
            "assets/shared/sounds/", "content/sounds/",
            "assets/shared/music/", "content/music/",
            "assets/shared/videos/", "content/videos/",
            "assets/shared/stages/", "content/stages/",
            "assets/shared/noteskins/", "content/noteskins/",
            "assets/shared/shaders/", "content/shaders/",
            "assets/shared/weeks/", "content/weeks/"
        ];
        for (prefix in prefixes) {
            for (ext in exts) {
                var path = prefix + relPath + ext;
                if (AssetUtils.assetExists(path) || OpenFlAssets.exists(path))
                    return path;
            }
        }
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

    // --- UNIVERSAL FILE CHECKER ---
	
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
		NativeAPI.showMessageBox("Path Error", "The TEXT from the file \"" + key + "\" could not be found. Please check the file path or ensure the text file exists in the assets or mods folder.");
		return '';
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

    // --- MODS/CONTENT HELPERS ---

    inline static public function mods(key:String = ""):String {
        return "$MODS_DIRECTORY/" + key;
    }

    inline static public function modsFont(key:String):String {
        return findAnyAsset('fonts/' + key, ['.ttf', '.otf']);
    }

    inline static public function modsJson(key:String):String {
        return findAnyAsset('songs/' + key, ['.json']);
    }

    inline static public function modsVideo(key:String):String {
        return findAnyAsset('videos/' + key, ['.' + VIDEO_EXT]);
    }

    inline static public function modsSounds(path:String, key:String):String {
        return findAnyAsset('sounds/' + key, ['.' + SOUND_EXT]);
    }

    inline static public function modsImages(key:String):String {
        return findAnyAsset('images/' + key, ['.png']);
    }

    inline static public function modsXml(key:String):String {
        return findAnyAsset('images/' + key, ['.xml']);
    }

    inline static public function modsTxt(key:String):String {
        return findAnyAsset('images/' + key, ['.txt']);
    }

    public static function modsShaderFragment(key:String, ?library:String):Null<String>
    {
        var shaderPath = Paths.findAnyAsset('shaders/' + key, ['.frag']);
        if (shaderPath != null) {
            var shaderContent = mobile.backend.AssetUtils.getAssetContent(shaderPath);
        }
        return findAsset('shaders/$key.frag'); // fallback
    }

    public static function modsShaderVertex(key:String, ?library:String):Null<String> {
        return findAsset('shaders/$key.vert');
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
            //NativeAPI.showMessageBox("Path Error", "The Mod texture \"" + key + "\" could not be found. Please check if the .atlas file is present in the assets or mods folder.\n" + Std.string(e));
            return null;
        }
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

    // --- UTILS ---

    public static function getContent(asset:String):Null<String>
	{
		if (Assets.exists(asset)) return Assets.getText(asset);
		
		trace('oh no its returning null NOOOO ($asset)');
		return null;
	}

    public static function formatToSongPath(path:String) {
		return path.toLowerCase().replace(' ', '-'); // example: formatToSongPath("Ugh Oh") make this way: assets/songs/ugh-oh/Inst.ogg, Voices.ogg, or others
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
}