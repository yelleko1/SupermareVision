package funkin.backend;

@:nullSafety
class FallbackState extends MusicBeatState
{
	final warningMessage:String;
	
	final continueCallback:Void->Void;
	
	public function new(warningMessage:String, continueCallback:Void->Void)
	{
		this.continueCallback = continueCallback;
		this.warningMessage = warningMessage;
		super();
	}
	
	override function create()
	{
		var bg = new FlxSprite().loadGraphic(Paths.image('uhoh'));
		bg.setGraphicSize(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		
		var error = new FlxText(0, 0, 0, 'ERROR', 46);
		error.setFormat(Paths.DEFAULT_FONT, 46, FlxColor.RED, LEFT, OUTLINE, FlxColor.BLACK);
		error.screenCenter(X);
		error.y = 25;
		error.antialiasing = ClientPrefs.globalAntialiasing;
		add(error);
		FlxTween.tween(error, {y: error.y + 45}, 2, {ease: FlxEase.sineInOut, type: PINGPONG});
		
		var text = new FlxText(25, 0, FlxG.width - 50, warningMessage, 32);
		text.setFormat(Paths.DEFAULT_FONT, 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		text.antialiasing = ClientPrefs.globalAntialiasing;
		add(text);
		text.screenCenter(Y);
		
		var continueText = new FlxText(0, FlxG.height - 36 - 32, FlxG.width, 'Press Confirm to continue.', 32);
		continueText.setFormat(Paths.DEFAULT_FONT, 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		continueText.antialiasing = ClientPrefs.globalAntialiasing;
		add(continueText);
		
		var restartText = new FlxText(0, FlxG.height - 32, FlxG.width, 'Press F5 to restart the game.', 32);
		restartText.setFormat(Paths.DEFAULT_FONT, 32, FlxColor.RED, CENTER, OUTLINE, FlxColor.BLACK);
		restartText.antialiasing = ClientPrefs.globalAntialiasing;
		add(restartText);
		
		super.create();
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (controls.ACCEPT)
		{
			persistentUpdate = false;
			continueCallback();
		}
		
		if (FlxG.keys.justPressed.F5)
		{
			var exePath:String = Sys.programPath();
			
			Sys.command("cmd", [
				"/c",
				"start",
				"",
				exePath
			]);
			
			Sys.exit(0);
		}
	}
}
