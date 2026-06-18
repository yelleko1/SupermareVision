package funkin.objects.note;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;

import openfl.display.BitmapData;

import funkin.data.*;
import funkin.objects.Bopper;
import funkin.game.shaders.RGBShader;

class NoteSplash extends FunkinSprite implements funkin.game.modchart.IModNote
{
	public var rgbGraphics:RGBGraphics = new RGBGraphics();
	
	public var data(get, set):Int;
	public var noteData:Int = 0;
	
	public var player:Int = 0;
	
	private var _note:Note;
	private var _strum:StrumNote;
	
	@:noCompletion var _textureLoaded:Null<String> = null;
	
	public var skin:NoteSkin;
	
	public function new(x:Float = 0, y:Float = 0, noteData:Int = 0, player:Int = 0)
	{
		super(x, y);
		
		skin = NoteUtil.getSkinFromID(player);
		
		addAnims();
	}
	
	function addAnims()
	{
		if (skin != null && skin.splashAtlas != null)
		{
			frames = skin.splashAtlas;
		}
		else
		{
			var _skin:String = 'noteSplashes';
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
					frames = Paths.getSparrowAtlas(_skin);
				}
			}
			else
			{
				frames = Paths.getSparrowAtlas(_skin);
			}
		}
		
		if (frames == null) return;
		
		final animData = skin.splashAnims ?? NoteUtil.DEFAULT_NOTESPLASH_ANIMATIONS;
		
		for (noteData in 0...skin.keys)
		{
			if (animData[noteData] == null || animData[noteData].anim == null || animData[noteData].xmlName == null) continue;
			
			final animName = animData[noteData].anim;
			final offsets = animData[noteData].offsets;
			
			animation.addByPrefix(animName, animData[noteData].xmlName, animData[noteData].fps != null ? animData[noteData].fps : 24, false);
			addOffset(animName, offsets[0], offsets[1]);
		}
		
		animation.onFinish.add((animName) -> {
			kill();
		});
	}
	
	public override function playAnim(anim:String, force:Bool = false, isReversed:Bool = false, frame:Int = 0)
	{
		if (animation.getByName(anim) == null) return;
		
		super.playAnim(anim, force, isReversed, frame);
		
		centerOffsets();
		centerOrigin();
	}
	
	public function setColors(?colors:Array<FlxColor>):Void
	{
		if (colors == null || skin == null) return;
		
		final sanitzedColourArray = colors ?? NoteUtil.colorToArray(skin.colors[data]);
		
		rgbGraphics.enabled = skin.inEngineColoring;
		rgbGraphics.setColors(sanitzedColourArray);
	}
	
	public function setupSplash(strum:StrumNote, ?note:Note, ?graphicsInput:RGBGraphics, ?field:PlayField)
	{
		if (note == null)
		{
			this._strum = strum;
			this._note = null;
			data = 0;
		}
		else
		{
			this._note = note;
			this._strum = strum;
			data = note.noteData;
		}
		
		visible = true;
		angle = 0;
		alpha = 1;
		
		this.player = field?.player ?? 0;
		
		skin = NoteUtil.getSkinFromID(player);
		
		antialiasing = skin.antialiasing;
		
		if (skin?.splashScale != null) scale.set(skin.splashScale, skin.splashScale);
		
		baseScale.copyFrom(scale);
		
		updateHitbox();
		
		playAnim('note$data', true);
		
		setColors(graphicsInput?.getColors());
		
		if (field != null && !field.trackNoteSplashes) _position();
	}
	
	function _position()
	{
		if (_strum != null)
		{
			final _skin:NoteSkin = NoteUtil.getSkinFromID(player);
			
			final offsets = _skin.splashOffsets != null ? _skin.splashOffsets[data] : null;
			
			setPosition(_strum.x + (_strum.width - width) * .5, _strum.y + (_strum.height - height) * .5);
			spriteOffset.set(offsets?.x, offsets?.y);
		}
	}
	
	inline function get_data():Int return noteData;
	
	inline function set_data(v:Int):Int return noteData = v;
	
	override function update(elapsed:Float)
	{
		if (animation.curAnim != null && animation.curAnim.finished) kill();
		
		super.update(elapsed);
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
