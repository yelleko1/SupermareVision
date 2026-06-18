package funkin.data;

import haxe.ds.Vector;

import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;

import openfl.display.BitmapData;

import funkin.data.NoteSkin.Animation;
import funkin.data.NoteSkin.ColorList;

class NoteSkin implements IFlxDestroyable
{
	public var data:NoteSkinData;
	
	public var name:String = '';
	public var keys:Int = 4;
	public var ID:Int = 0;
	
	public var noteTexture:String = '';
	public var splashTexture:String = '';
	public var sustainSplashTexture:String = '';
	
	public var noteAnims:Array<Array<Animation>> = [];
	public var receptorAnims:Array<Array<Animation>> = [];
	public var splashAnims:Array<Animation> = [];
	public var susSplashAnims:Array<Array<Animation>> = [];
	
	public var noteOffsets:Vector<FlxPoint>;
	public var sustainOffsets:Vector<FlxPoint>;
	public var susEndOffsets:Vector<FlxPoint>;
	public var splashOffsets:Vector<FlxPoint>;
	public var sustainSplashOffsets:Vector<FlxPoint>;
	public var receptorOffsets:Vector<FlxPoint>;
	
	public var quantsEnabled:Bool = true;
	public var splashesEnabled:Bool = true;
	public var sustainSplashes:Bool = true;
	public var antialiasing:Bool = true;
	
	public var receptorAlpha:Float = 1.0;
	public var sustainAlpha:Float = 1.0;
	public var splashAlpha:Float = 1.0;
	public var susSplashAlpha:Float = 1.0;
	
	public var receptorScale:Float = 0.7;
	public var noteScale:Float = 0.7;
	public var splashScale:Float = 1;
	public var susSplashScale:Float = 1;
	
	public var inEngineColoring:Bool = true;
	public var colors:Array<ColorList> = [];
	
	public var singAnimations = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	
	public var noteAtlas:FlxAtlasFrames;
	public var splashAtlas:FlxAtlasFrames;
	public var sustainSplashAtlas:FlxAtlasFrames;
	
	public function new(path:String, _keys:Int = -1, id:Int = 0)
	{
		keys = _keys;
		name = path;
		this.ID = id;
		
		noteOffsets = new Vector<FlxPoint>(keys);
		sustainOffsets = new Vector<FlxPoint>(keys);
		susEndOffsets = new Vector<FlxPoint>(keys);
		receptorOffsets = new Vector<FlxPoint>(keys);
		splashOffsets = new Vector<FlxPoint>(keys);
		sustainSplashOffsets = new Vector<FlxPoint>(keys);
		
		for (i in 0...keys)
		{
			noteOffsets[i] = new FlxPoint();
			receptorOffsets[i] = new FlxPoint();
			sustainOffsets[i] = new FlxPoint();
			susEndOffsets[i] = new FlxPoint();
			splashOffsets[i] = new FlxPoint();
			sustainSplashOffsets[i] = new FlxPoint();
		}
		
		noteTexture = 'notes';
		splashTexture = 'splashes';
		sustainSplashTexture = 'sustains';
		
		var data:NoteSkinData = loadFromPath(name);
		
		noteAnims = data.noteAnimations ?? NoteUtil.DEFAULT_NOTE_ANIMATIONS;
		receptorAnims = data.receptorAnimations ?? NoteUtil.DEFAULT_RECEPTOR_ANIMATIONS;
		splashAnims = data.noteSplashAnimations ?? NoteUtil.DEFAULT_NOTESPLASH_ANIMATIONS;
		susSplashAnims = data.susSplashAnimations ?? NoteUtil.DEFAULT_SUSTAIN_SPLASH_ANIMATIONS;
		
		if (data.singAnimations != null) singAnimations = data.singAnimations;
		if (data.splashesEnabled != null) splashesEnabled = data.splashesEnabled;
		if (data.susSplashesEnabled != null) sustainSplashes = data.susSplashesEnabled;
		if (data.antialiasing != null) antialiasing = data.antialiasing;
		
		if (data.receptorAlpha != null) receptorAlpha = data.receptorAlpha;
		if (data.sustainAlpha != null) sustainAlpha = data.sustainAlpha;
		if (data.splashAlpha != null) splashAlpha = data.splashAlpha;
		if (data.susSplashAlpha != null) susSplashAlpha = data.susSplashAlpha;
		
		if (data.receptorScale != null) receptorScale = data.receptorScale;
		if (data.noteScale != null) noteScale = data.noteScale;
		if (data.splashScale != null) splashScale = data.splashScale;
		if (data.susSplashScale != null) susSplashScale = data.susSplashScale;
		
		if (data.inGameColoring != null) inEngineColoring = data.inGameColoring;
		if (data.arrowRGB != null) colors = data.arrowRGB;
		else colors = NoteUtil.defaultColors.copy();
		
		loadTextures();
		buildOffsets();
	}
	
	function loadTextures():Void
	{
		noteAtlas = loadTexture('notes');
		splashAtlas = loadTexture('splashes');
		sustainSplashAtlas = loadTexture('sustains');
	}
	
	function loadTexture(type:String):FlxAtlasFrames
	{
		var fullPath:String = '';
		var found:Bool = false;
		
		var possiblePaths:Array<String> = [Paths.mods(Mods.currentModDirectory + '/game/noteskins/' + name + '/' + type + '/image.png'),
			Paths.mods(Mods.currentModDirectory + '/game/noteskins/' + name + '/' + type + '.png'),
			Paths.mods(Mods.currentModDirectory + '/game/noteskins/default/' + type + '/image.png'),
			Paths.mods(Mods.currentModDirectory + '/game/noteskins/default/' + type + '.png'),
			'game/noteskins/'
			+ name
			+ '/'
			+ type
			+ '/image.png',
			'game/noteskins/default/' + type + '/image.png'
		];
		
		#if MODS_ALLOWED
		for (mod in Mods.globalMods)
		{
			possiblePaths.push(Paths.mods(mod + '/game/noteskins/' + name + '/' + type + '/image.png'));
			possiblePaths.push(Paths.mods(mod + '/game/noteskins/' + name + '/' + type + '.png'));
			possiblePaths.push(Paths.mods(mod + '/game/noteskins/default/' + type + '/image.png'));
			possiblePaths.push(Paths.mods(mod + '/game/noteskins/default/' + type + '.png'));
		}
		#end
		
		for (path in possiblePaths)
		{
			if (sys.FileSystem.exists(path))
			{
				fullPath = path;
				found = true;
				break;
			}
		}
		
		if (!found)
		{
			var corePath:String = Paths.getCorePath('data/noteskins/$name/$type');
			if (FunkinAssets.exists(corePath + '.png'))
			{
				fullPath = corePath + '.png';
				found = true;
			}
			else if (FunkinAssets.exists(corePath + '/image.png'))
			{
				fullPath = corePath + '/image.png';
				found = true;
			}
		}
		
		if (found)
		{
			return loadAtlasFromFile(fullPath);
		}
		
		return null;
	}
	
	function loadAtlasFromFile(filePath:String):FlxAtlasFrames
	{
		var bmp = BitmapData.fromFile(filePath);
		var graphic = FlxGraphic.fromBitmapData(bmp);
		
		var xmlPath = filePath.substr(0, filePath.length - 4) + '.xml';
		if (!sys.FileSystem.exists(xmlPath))
		{
			var dir = filePath.substr(0, filePath.lastIndexOf('/') + 1);
			xmlPath = dir + 'sheet.xml';
		}
		
		if (sys.FileSystem.exists(xmlPath))
		{
			var xml = Xml.parse(sys.io.File.getContent(xmlPath));
			return FlxAtlasFrames.fromSparrow(graphic, xml);
		}
		
		var txtPath = filePath.substr(0, filePath.length - 4) + '.txt';
		if (sys.FileSystem.exists(txtPath))
		{
			var txt = sys.io.File.getContent(txtPath);
			return FlxAtlasFrames.fromSpriteSheetPacker(graphic, txt);
		}
		
		var jsonPath = filePath.substr(0, filePath.length - 4) + '.json';
		if (sys.FileSystem.exists(jsonPath))
		{
			var json = sys.io.File.getContent(jsonPath);
			return FlxAtlasFrames.fromAseprite(graphic, json);
		}
		
		return null;
	}
	
	function buildOffsets():Void
	{
		for (i in 0...keys)
		{
			if (receptorAnims.length > i && receptorAnims[i].length > 0)
			{
				var offsets = receptorAnims[i][0].offsets;
				if (offsets != null && offsets.length >= 2)
				{
					receptorOffsets[i].set(offsets[0], offsets[1]);
				}
			}
			
			if (noteAnims.length > i && noteAnims[i].length > 0)
			{
				var offsets = noteAnims[i][0].offsets;
				if (offsets != null && offsets.length >= 2)
				{
					noteOffsets[i].set(offsets[0], offsets[1]);
				}
				
				if (noteAnims[i].length > 1)
				{
					var holdOffsets = noteAnims[i][1].offsets;
					if (holdOffsets != null && holdOffsets.length >= 2)
					{
						sustainOffsets[i].set(holdOffsets[0], holdOffsets[1]);
					}
				}
				
				if (noteAnims[i].length > 2)
				{
					var endOffsets = noteAnims[i][2].offsets;
					if (endOffsets != null && endOffsets.length >= 2)
					{
						susEndOffsets[i].set(endOffsets[0], endOffsets[1]);
					}
				}
			}
			
			if (splashAnims.length > i)
			{
				var offsets = splashAnims[i].offsets;
				if (offsets != null && offsets.length >= 2)
				{
					splashOffsets[i].set(offsets[0], offsets[1]);
				}
			}
			
			if (susSplashAnims.length > i && susSplashAnims[i].length > 0)
			{
				var offsets = susSplashAnims[i][0].offsets;
				if (offsets != null && offsets.length >= 2)
				{
					sustainSplashOffsets[i].set(offsets[0], offsets[1]);
				}
			}
		}
	}
	
	public function loadFromPath(path:String):NoteSkinData
	{
		var _data:NoteSkinData = {};
		
		var configPath:String = '';
		var found:Bool = false;
		
		var possibleConfigPaths:Array<String> = [
			Paths.mods(Mods.currentModDirectory + '/game/noteskins/' + path + '/config.json'),
			Paths.mods(Mods.currentModDirectory + '/game/noteskins/default/config.json'),
			'game/noteskins/' + path + '/config.json',
			'game/noteskins/default/config.json'
		];
		
		#if MODS_ALLOWED
		for (mod in Mods.globalMods)
		{
			possibleConfigPaths.push(Paths.mods(mod + '/game/noteskins/' + path + '/config.json'));
			possibleConfigPaths.push(Paths.mods(mod + '/game/noteskins/default/config.json'));
		}
		#end
		
		for (p in possibleConfigPaths)
		{
			if (sys.FileSystem.exists(p))
			{
				configPath = p;
				found = true;
				break;
			}
		}
		
		if (!found)
		{
			var corePath:String = Paths.getCorePath('data/noteskins/' + path + '/config.json');
			if (FunkinAssets.exists(corePath))
			{
				configPath = corePath;
				found = true;
			}
		}
		
		if (found)
		{
			try
			{
				_data = cast haxe.Json.parse(sys.io.File.getContent(configPath));
			}
			catch (e:Dynamic)
			{
				trace('Failed to parse noteskin config for $path: $e');
			}
		}
		
		resolveData(_data);
		
		return _data;
	}
	
	public static function resolveData(data:NoteSkinData)
	{
		inline function correctAnims(input:Array<Animation>)
		{
			for (i in input)
			{
				if (i.offsets == null) i.offsets = [0, 0];
				if (i.looping == null) i.looping = false;
				if (i.fps == null) i.fps = 24;
			}
		}
		
		data.noteTexture ??= 'notes';
		data.splashTexture ??= 'splashes';
		data.sustainSplashTexture ??= 'sustains';
		
		data.antialiasing ??= true;
		
		data.noteAnimations ??= NoteUtil.DEFAULT_NOTE_ANIMATIONS;
		data.receptorAnimations ??= NoteUtil.DEFAULT_RECEPTOR_ANIMATIONS;
		data.noteSplashAnimations ??= NoteUtil.DEFAULT_NOTESPLASH_ANIMATIONS;
		data.susSplashAnimations ??= NoteUtil.DEFAULT_SUSTAIN_SPLASH_ANIMATIONS;
		
		for (j in [data.noteAnimations, data.receptorAnimations, data.susSplashAnimations])
		{
			if (j != null)
			{
				for (i in j)
					if (i != null) correctAnims(i);
			}
		}
		if (data.noteSplashAnimations != null) correctAnims(data.noteSplashAnimations);
		
		data.singAnimations ??= NoteUtil.defaultSingAnimations;
		data.splashesEnabled ??= true;
		data.susSplashesEnabled ??= true;
		
		data.receptorAlpha ??= 1.0;
		data.sustainAlpha ??= 1.0;
		data.splashAlpha ??= 1.0;
		data.susSplashAlpha ??= 1.0;
		
		data.receptorScale ??= 0.7;
		data.noteScale ??= 0.7;
		data.splashScale ??= 1;
		data.susSplashScale ??= 1;
		
		data.arrowRGB ??= NoteUtil.defaultColors.copy();
		data.inGameColoring ??= true;
	}
	
	public function destroy()
	{
		for (i in 0...keys)
		{
			if (noteOffsets != null && noteOffsets[i] != null) noteOffsets[i].put();
			if (sustainOffsets != null && sustainOffsets[i] != null) sustainOffsets[i].put();
			if (susEndOffsets != null && susEndOffsets[i] != null) susEndOffsets[i].put();
			if (receptorOffsets != null && receptorOffsets[i] != null) receptorOffsets[i].put();
			if (splashOffsets != null && splashOffsets[i] != null) splashOffsets[i].put();
			if (sustainSplashOffsets != null && sustainSplashOffsets[i] != null) sustainSplashOffsets[i].put();
		}
		
		noteOffsets = null;
		sustainOffsets = null;
		susEndOffsets = null;
		receptorOffsets = null;
		splashOffsets = null;
		sustainSplashOffsets = null;
		
		if (noteAtlas != null)
		{
			noteAtlas.destroy();
			noteAtlas = null;
		}
		if (splashAtlas != null)
		{
			splashAtlas.destroy();
			splashAtlas = null;
		}
		if (sustainSplashAtlas != null)
		{
			sustainSplashAtlas.destroy();
			sustainSplashAtlas = null;
		}
	}
}

typedef NoteSkinData =
{
	?noteTexture:String,
	?splashTexture:String,
	?sustainSplashTexture:String,
	
	?antialiasing:Bool,
	?singAnimations:Array<String>,
	
	?noteAnimations:Array<Array<Animation>>,
	?receptorAnimations:Array<Array<Animation>>,
	?noteSplashAnimations:Array<Animation>,
	?susSplashAnimations:Array<Array<Animation>>,
	
	?splashesEnabled:Bool,
	?susSplashesEnabled:Bool,
	
	?receptorAlpha:Float,
	?sustainAlpha:Float,
	?splashAlpha:Float,
	?susSplashAlpha:Float,
	
	?receptorScale:Float,
	?noteScale:Float,
	?splashScale:Float,
	?susSplashScale:Float,
	
	?inGameColoring:Bool,
	?arrowRGB:Array<ColorList>
}

typedef Animation =
{
	?anim:String,
	?xmlName:String,
	?offsets:Array<Float>,
	?looping:Bool,
	?fps:Int
}

typedef ColorList =
{
	?r:FlxColor,
	?g:FlxColor,
	?b:FlxColor
}
