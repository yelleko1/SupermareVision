package funkin.objects.note;

import funkin.backend.math.Vector3;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;

import openfl.display.BitmapData;

import funkin.objects.*;
import funkin.game.shaders.RGBShader;
import funkin.states.*;
import funkin.data.*;

class StrumNote extends FunkinSprite implements funkin.game.modchart.IModNote
{
	public var intThing:Int = 0;
	
	public var resetAnim:Float = 0;
	public var noteData:Int = 0;
	public var direction:Float = 90;
	public var downScroll:Bool = false;
	public var sustainReduce:Bool = true;
	public var isQuant:Bool = false;
	public var player:Int;
	public var targetAlpha:Float = 1;
	public var alphaMult:Float = 1;
	public var parent:PlayField;
	@:isVar
	public var swagWidth(get, null):Float;
	
	public function get_swagWidth()
	{
		return parent == null ? Note.swagWidth : parent.swagWidth;
	}
	
	public var z:Float = 0;
	
	override function set_alpha(val:Float)
	{
		return targetAlpha = val;
	}
	
	public var texture(default, set):String = null;
	
	private function set_texture(value:String):String
	{
		if (texture != value)
		{
			texture = value;
			reloadNote();
		}
		return value;
	}
	
	public var rgbGraphics:RGBGraphics = new RGBGraphics();
	public var useRGBShader:Bool = true;
	
	public var skin:NoteSkin;
	
	public function new(player:Int, x:Float, y:Float, leData:Int, ?parent:PlayField)
	{
		noteData = leData;
		this.noteData = leData;
		this.parent = parent;
		this.player = player;
		super(x, y);
		
		if (skin == null)
		{
			skin = NoteUtil.getSkinFromID(parent?.player ?? 0);
		}
		
		texture = skin.noteTexture;
		
		scrollFactor.set();
		
		useRGBShader = skin.inEngineColoring;
		rgbGraphics.enabled = useRGBShader;
		
		isQuant = parent?.quants ?? ClientPrefs.quants;
		
		handleColors();
	}
	
	public var lastNote:Null<Note> = null;
	
	public function handleColors(anim:String = '', ?note:Note)
	{
		if (!useRGBShader) return;
		
		note ??= lastNote;
		lastNote = note;
		
		final fallback = skin.colors != null ? NoteUtil.colorToArray(skin.colors[noteData]) : NoteUtil.getCurColors(noteData, (isQuant && note != null) ? note.quant : 4, player)
			.getColors();
			
		var arr:Array<FlxColor> = note?.rgbGraphics?.getColors();
		if (arr == null) arr = fallback;
		
		if (isQuant && anim == 'pressed') arr = ClientPrefs.arrowRGBquant[0];
		
		if (rgbGraphics != null)
		{
			rgbGraphics.setColors(arr);
			
			rgbGraphics.enabled = (anim != 'static');
		}
	}
	
	public function reloadNote()
	{
		var lastAnim:String = null;
		if (animation.curAnim != null) lastAnim = animation.curAnim.name;
		
		if (skin != null && skin.noteAtlas != null)
		{
			frames = skin.noteAtlas;
		}
		else
		{
			var _skin:String = texture;
			if (_skin == null || _skin.length < 1) _skin = 'notes';
			
			var fullPath:String = '';
			var found:Bool = false;
			
			var possiblePaths:Array<String> = [Paths.mods(Mods.currentModDirectory + '/game/noteskins/' + (skin?.name ?? 'default') + '/' + _skin + '/image.png'),
				Paths.mods(Mods.currentModDirectory + '/game/noteskins/' + (skin?.name ?? 'default') + '/' + _skin + '.png'),
				Paths.mods(Mods.currentModDirectory + '/game/noteskins/default/' + _skin + '/image.png'),
				Paths.mods(Mods.currentModDirectory + '/game/noteskins/default/' + _skin + '.png'),
				'game/noteskins/'
				+ (skin?.name ?? 'default')
				+ '/'
				+ _skin
				+ '/image.png',
				'game/noteskins/default/'
				+ _skin
				+ '/image.png'];
				
			#if MODS_ALLOWED
			for (mod in Mods.globalMods)
			{
				possiblePaths.push(Paths.mods(mod + '/game/noteskins/' + (skin?.name ?? 'default') + '/' + _skin + '/image.png'));
				possiblePaths.push(Paths.mods(mod + '/game/noteskins/' + (skin?.name ?? 'default') + '/' + _skin + '.png'));
				possiblePaths.push(Paths.mods(mod + '/game/noteskins/default/' + _skin + '/image.png'));
				possiblePaths.push(Paths.mods(mod + '/game/noteskins/default/' + _skin + '.png'));
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
			
			if (found)
			{
				var bmp = BitmapData.fromFile(fullPath);
				var graphic = FlxGraphic.fromBitmapData(bmp);
				
				var xmlPath = fullPath.substr(0, fullPath.length - 4) + '.xml';
				if (!sys.FileSystem.exists(xmlPath))
				{
					var dir = fullPath.substr(0, fullPath.lastIndexOf('/') + 1);
					xmlPath = dir + 'sheet.xml';
				}
				
				if (sys.FileSystem.exists(xmlPath))
				{
					var xml = Xml.parse(sys.io.File.getContent(xmlPath));
					frames = FlxAtlasFrames.fromSparrow(graphic, xml);
				}
				else
				{
					frames = Paths.getAtlasFrames(_skin);
				}
			}
			else
			{
				frames = Paths.getAtlasFrames(_skin);
			}
		}
		
		setGraphicSize(Std.int(width * skin.receptorScale));
		
		loadAnimations();
		
		baseScale.copyFrom(scale);
		updateHitbox();
		
		antialiasing = skin.antialiasing;
		
		if (lastAnim != null) playAnim(lastAnim, true);
		
		handleColors();
	}
	
	function loadAnimations()
	{
		var noteAnims = skin.receptorAnims;
		var directionAnims = noteAnims[noteData % noteAnims.length];
		
		for (anim in directionAnims)
			addAnim(anim);
	}
	
	function addAnim(_anim:funkin.data.NoteSkin.Animation)
	{
		final anim = _anim ?? NoteUtil.fallbackReceptorAnims[0];
		
		if (!hasAnim(anim.anim))
		{
			animation.addByPrefix(anim.anim, anim.xmlName, anim.fps, anim.looping);
			addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
		}
	}
	
	public function postAddedToGroup()
	{
		playAnim('static');
		x -= swagWidth / 2;
		x = x - (swagWidth * 2) + (swagWidth * noteData) + 54;
		
		ID = noteData;
	}
	
	override function update(elapsed:Float)
	{
		if (resetAnim > 0)
		{
			resetAnim -= elapsed;
			if (resetAnim <= 0)
			{
				playAnim('static');
				resetAnim = 0;
			}
		}
		@:bypassAccessor
		super.set_alpha(targetAlpha * alphaMult);
		
		super.update(elapsed);
	}
	
	public override function playAnim(anim:String, force:Bool = false, isReversed:Bool = false, frame:Int = 0)
	{
		super.playAnim(anim, force, isReversed, frame);
		
		centerOffsets();
		centerOrigin();
		
		handleColors(anim);
	}
	
	override function drawSimple(camera:FlxCamera)
	{
		super.drawSimple(camera);
		rgbGraphics.pushQuad(camera);
	}
	
	override function drawComplex(camera:FlxCamera)
	{
		super.drawComplex(camera);
		rgbGraphics.pushQuad(camera);
	}
}
