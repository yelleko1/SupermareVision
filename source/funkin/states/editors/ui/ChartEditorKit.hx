package funkin.states.editors.ui;

import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.components.Label;
import haxe.ui.components.TextField;
import haxe.ui.containers.HBox;
import haxe.ui.containers.Box;

import funkin.data.CharacterData;

using funkin.states.editors.ui.ToolKitUtils;

import flixel.util.FlxTimer;

@:build(haxe.ui.ComponentBuilder.build("assets/excluded/ui/chartEditor/SongDialog.xml"))
class SongDialog extends Dialog {}

@:access(funkin.states.editors.ChartEditorState)
class ChartEditorUI extends flixel.group.FlxSpriteContainer
{
	public var songDialog:SongDialog;
	
	public var song:funkin.data.Song;
	public var charter:ChartEditorState;
	
	var eventUpdateTimer:FlxTimer = null;
	
	public function new(charter:ChartEditorState)
	{
		super();
		
		this.charter = charter;
		this.song = ChartEditorState.song;
		
		songDialog = new SongDialog();
		add(songDialog);
		
		songDialog.x = 15;
		songDialog.y = 50;
		
		songDialog.destroyOnClose = false;
		songDialog.bindDialogToView(0); // cahrt editor wont have a toolbar so we can set the min y to be 0
		
		songDialog.showDialog(false);
		
		bind();
	}
	
	public function bind():Void
	{
		if (charter == null) return;
		
		// METADATA
		
		songDialog.songNameField.value = song.song;
		songDialog.songNameField.onChange = function(event) song.song = songDialog.songNameField.value;
		
		songDialog.initialBpmStepper.value = song.bpm;
		songDialog.initialBpmStepper.onChange = function(event) {
			Conductor.bpm = song.bpm = event.value;
			Conductor.mapBPMChanges(song);
		}
		
		songDialog.songSpeedStepper.value = song.speed;
		songDialog.songSpeedStepper.onChange = function(event) song.speed = event.value;
		
		songDialog.strumsStepper.value = song.lanes;
		songDialog.strumsStepper.onChange = function(event) {
			song.lanes = ChartEditorState.lanes = event.value;
			
			charter.reloadStrumShit();
			charter.updateGrid();
			charter.reloadGridLayer();
			
			charter.gridZoom();
		}
		
		songDialog.keysStepper.value = song.keys;
		songDialog.keysStepper.onChange = function(event) {
			song.keys = event.value;
			
			charter.reloadStrumShit();
			charter.updateGrid();
			charter.reloadGridLayer();
			
			charter.gridZoom();
		}
		
		// Global time signature removed from metadata UI; sections still have time signature controls.
		
		refreshCharacterDropdowns();
		refreshStageDropdown();
		refreshSkinDropdown();
		
		songDialog.bfDropdown.onChange = function(event) {
			if (!event.data.isDropDownItem()) return;
			
			charter.bfIcon = CharacterParser.fetchInfo(song.player1 = event.data.id).healthicon;
			charter.updateHeads();
		}
		songDialog.dadDropdown.onChange = function(event) {
			if (!event.data.isDropDownItem()) return;
			
			charter.dadIcon = CharacterParser.fetchInfo(song.player2 = event.data.id).healthicon;
			charter.updateHeads();
		}
		songDialog.gfDropdown.onChange = function(event) {
			if (!event.data.isDropDownItem()) return;
			
			charter.gfIcon = CharacterParser.fetchInfo(song.gfVersion = event.data.id).healthicon;
			charter.updateHeads();
		}
		
		// rewrite this later cuz its an array now
		// songDialog.noteSkinDropdown.onChange = function(event) {
		// 	if (!event.data.isDropDownItem()) return;
		
		// 	song.arrowSkins = event.data.id;
		// 	// todo
		// }
		
		// CHARTING
		
		songDialog.vortexCheckbox.value = FlxG.save.data.chart_vortex;
		songDialog.vortexCheckbox.onChange = function(event) {
			FlxG.save.data.chart_vortex = ChartEditorState.vortex = event.value.toBool();
			charter.reloadGridLayer();
		}
		
		songDialog.mouseWheelQuantCheckbox.value = FlxG.save.data.mouseScrollingQuant;
		songDialog.mouseWheelQuantCheckbox.onChange = function(event) {
			FlxG.save.data.mouseScrollingQuant = charter.mouseQuant = event.value.toBool();
		}
		
		songDialog.playbackRateSlider.onChange = function(event) {
			charter.playbackSpeed = songDialog.playbackRateSlider.value;
		}
		
		songDialog.playerWaveCheckbox.value = FlxG.save.data.chart_waveformVoice;
		songDialog.playerWaveCheckbox.onChange = function(event) {
			FlxG.save.data.chart_waveformVoices = event.value.toBool();
			charter.updateWaveform(true);
		}
		songDialog.opponentWaveCheckbox.value = FlxG.save.data.chart_waveformOpponentVoice;
		songDialog.opponentWaveCheckbox.onChange = function(event) {
			FlxG.save.data.chart_waveformOpponentVoices = event.value.toBool();
			charter.updateWaveform(true);
		}
		songDialog.instrumentalWaveCheckbox.value = FlxG.save.data.chart_waveformInst;
		songDialog.instrumentalWaveCheckbox.onChange = function(event) {
			FlxG.save.data.chart_waveformInst = event.value.toBool();
			charter.updateWaveform(true);
		}
		
		songDialog.playerVolumeStepper.onChange = function(event) charter.updateVolume();
		songDialog.opponentVolumeStepper.onChange = function(event) charter.updateVolume();
		songDialog.instrumentalVolumeStepper.onChange = function(event) charter.updateVolume();
		songDialog.metronomeVolumeStepper.onChange = function(event) charter.updateVolume();
		
		songDialog.playerMuteCheckbox.onChange = function(event) charter.updateVolume();
		songDialog.opponentMuteCheckbox.onChange = function(event) charter.updateVolume();
		songDialog.instrumentalMuteCheckbox.onChange = function(event) charter.updateVolume();
		songDialog.metronomeMuteCheckbox.onChange = function(event) charter.updateVolume();
		
		songDialog.playerHitsoundCheckbox.onChange = function(event) charter.bfHitsound = event.value;
		songDialog.opponentHitsoundCheckbox.onChange = function(event) charter.dadHitsound = event.value;
		
		songDialog.playbackRateSlider.onChange = function(event) {
			charter.playbackSpeed = songDialog.playbackRateSlider.value;
		}
		
		// SECTION
		
		songDialog.gfSectionCheckbox.onChange = function(event) {
			song.notes[ChartEditorState.curSec].gfSection = event.value;
			
			charter.reloadGridLayer();
			charter.updateHeads();
		}
		
		songDialog.timeSigNumStepper.onChange = function(event) {
			song.notes[ChartEditorState.curSec].timeSignatureNumerator = Std.int(event.value);
			Conductor.mapBPMChanges(song);
			charter.reloadGridLayer();
		}
		songDialog.timeSigDenStepper.onChange = function(event) {
			var allowedDenominators:Array<Int> = [2, 4, 8, 16];
			var val:Int = Std.int(event.value);
			
			if (!allowedDenominators.contains(val))
			{
				var prev:Int = Std.int(event.previousValue);
				var isIncreasing:Bool = val > prev;
				
				if (isIncreasing)
				{
					var found = false;
					for (d in allowedDenominators)
					{
						if (d >= val)
						{
							val = d;
							found = true;
							break;
						}
					}
					if (!found) val = 16;
				}
				else
				{
					var found = false;
					var i = allowedDenominators.length - 1;
					while (i >= 0)
					{
						if (allowedDenominators[i] <= val)
						{
							val = allowedDenominators[i];
							found = true;
							break;
						}
						i--;
					}
					if (!found) val = 2;
				}
				songDialog.timeSigDenStepper.value = val;
			}
			
			song.notes[ChartEditorState.curSec].timeSignatureDenominator = val;
			Conductor.mapBPMChanges(song);
			charter.reloadGridLayer();
		}
		songDialog.bpmCheckbox.onChange = function(event) {
			song.notes[ChartEditorState.curSec].changeBPM = event.value;
			Conductor.mapBPMChanges(song);
			
			charter.reloadGridLayer();
		}
		songDialog.bpmStepper.onChange = function(event) {
			song.notes[ChartEditorState.curSec].bpm = event.value;
			Conductor.mapBPMChanges(song);
			
			charter.updateGrid();
		}
		
		songDialog.copySectionButton.onClick = function(event) charter.copySection();
		songDialog.pasteSectionButton.onClick = function(event) charter.pasteSection();
		songDialog.clearSectionButton.onClick = function(event) charter.clearSection();
		songDialog.copyLastSectionButton.onClick = function(event) charter.cloneSection(songDialog.copyLastSectionStepper.value);
		
		// NOTES
		
		var _notesTabReady = false;
		songDialog.noteTypeDropdown.onChange = function(event) {
			charter.currentType = songDialog.noteTypeDropdown.selectedIndex;
			
			var changed:Bool = false;
			
			for (note in charter.curSelectedNotes)
			{
				if (note[2] == null) continue;
				
				note[3] = charter.noteTypeIntMap.get(charter.currentType);
				changed = true;
			}
			
			if (changed) charter.updateGrid();
		}
		songDialog.strumTimeStepper.onChange = function(event) {
			if (_notesTabReady) changeStrumTime(event.previousValue, event.value);
			FlxTimer.wait(0, function() _notesTabReady = true);
		}
		
		final deinc = songDialog.strumTimeStepper.findComponent('deinc', haxe.ui.components.Button);
		final inc = songDialog.strumTimeStepper.findComponent('inc', haxe.ui.components.Button);
		deinc.onClick = function(event) strumTimeStep(-1);
		inc.onClick = function(event) strumTimeStep(1);
		
		songDialog.sustainLengthStepper.onChange = function(event) if (_notesTabReady) changeSustainLength(event.previousValue, event.value);
		
		final deinc = songDialog.sustainLengthStepper.findComponent('deinc', haxe.ui.components.Button);
		final inc = songDialog.sustainLengthStepper.findComponent('inc', haxe.ui.components.Button);
		deinc.onClick = function(event) sustainLengthStep(-1);
		inc.onClick = function(event) sustainLengthStep(1);
		
		songDialog.mirrorHorizontalButton.onClick = function(event) {
			charter.mirrorNotes(charter.curSelectedNotes, X);
			
			charter.updateGrid();
		}
		songDialog.mirrorVerticalButton.onClick = function(event) {
			charter.mirrorNotes(charter.curSelectedNotes, Y);
			
			charter.updateGrid();
		}
		songDialog.choirNotesButton.onClick = function(event) {
			charter.choirNotes(charter.curSelectedNotes);
			
			charter.updateGrid();
		}
		songDialog.shiftNotesButton.onClick = function(event) {
			charter.transformNoteStrumlines(charter.curSelectedNotes, charter.shiftStrumlineTransform.bind());
			
			charter.updateGrid();
		}
		songDialog.swapNotesButton.onClick = function(event) {
			charter.transformNoteStrumlines(charter.curSelectedNotes, charter.swapStrumlineTransform.bind());
			
			charter.updateGrid();
		}
		
		// EVENTS
		
		songDialog.eventDropdown.onChange = function(event) {
			final selectedEvents = charter.getSelectedEvents();
			
			if (selectedEvents.length != 1 || selectedEvents[0][1][charter.curEventSelected] == null) return updateEventUI();
			
			var eventID:Int = songDialog.eventDropdown.selectedIndex;
			
			selectedEvents[0][1][charter.curEventSelected][0] = charter.eventStuff[eventID].name;
			
			charter.updateGrid();
			
			updateEventFields(selectedEvents[0][1][charter.curEventSelected]);
			updateEventUI();
		}
		
		songDialog.removeEventButton.onClick = function(event) {
			final selectedEvents = charter.getSelectedEvents();
			
			if (selectedEvents.length != 1) return;
			
			final event = selectedEvents[0];
			
			if (event[1].length > 1)
			{
				event[1].remove(event[1][charter.curEventSelected]);
			}
			else
			{
				song.events.remove(event);
				charter.curSelectedNotes.remove(event);
			}
			
			charter.curEventSelected = FlxMath.maxInt(charter.curEventSelected - 1, 0);
			charter.updateGrid();
			
			updateEventFields(selectedEvents[0][1][charter.curEventSelected]);
			updateEventUI();
		}
		songDialog.pushEventButton.onClick = function(event) {
			final selectedEvents = charter.getSelectedEvents();
			
			if (selectedEvents.length != 1) return;
			
			var evtDef = charter.eventStuff[songDialog.eventDropdown.selectedIndex];
			var name:String = '';
			if (evtDef != null) name = evtDef.name;
			else
			{
				var fallback = charter.eventStuff[songDialog.eventDropdown.selectedIndex];
				if (fallback != null)
				{
					if (Reflect.hasField(fallback, 'name')) name = Reflect.field(fallback, 'name');
					else if (Std.is(fallback, String)) name = Std.string(fallback);
				}
			}
			var vals:Array<String> = [];
			if (evtDef != null && evtDef.values != null) for (i in 0...evtDef.values.length)
				vals.push('');
			if (vals.length == 0)
			{
				vals.push('');
				vals.push('');
			}
			var newArr:Array<Dynamic> = [name];
			for (v in vals)
				newArr.push(v);
			cast(selectedEvents[0][1], Array<Dynamic>).push(newArr);
			charter.curEventSelected = Std.int(selectedEvents[0][1].length - 1);
			
			charter.updateGrid();
			
			updateEventFields(selectedEvents[0][1][charter.curEventSelected]);
			updateEventUI();
		}
		
		songDialog.selectedEventStepper.onChange = function(event) {
			final selectedEvents = charter.getSelectedEvents();
			
			if (selectedEvents.length != 1) return;
			
			charter.curEventSelected = songDialog.selectedEventStepper.selectedIndex;
			
			updateEventFields(selectedEvents[0][1][charter.curEventSelected]);
			updateEventUI();
		}
		
		songDialog.value1Field.onChange = function(event) {
			final selectedEvents = charter.getSelectedEvents();
			
			if (selectedEvents.length != 1 || selectedEvents[0][1][charter.curEventSelected] == null) return;
			
			selectedEvents[0][1][charter.curEventSelected][1] = songDialog.value1Field.value;
			scheduleGridUpdate();
		}
		songDialog.value2Field.onChange = function(event) {
			final selectedEvents = charter.getSelectedEvents();
			
			if (selectedEvents.length != 1 || selectedEvents[0][1][charter.curEventSelected] == null) return;
			
			selectedEvents[0][1][charter.curEventSelected][2] = songDialog.value2Field.value;
			scheduleGridUpdate();
		}
		
		songDialog.valueListField.onChange = function(event) {
			final selectedEvents = charter.getSelectedEvents();
			if (selectedEvents.length != 1 || selectedEvents[0][1][charter.curEventSelected] == null) return;
			
			var text = songDialog.valueListField.value;
			var parts = (text == null ? [] : text.split(','));
			for (i in 0...parts.length)
				parts[i] = parts[i].trim();
				
			var name = selectedEvents[0][1][charter.curEventSelected][0];
			var newArr:Array<Dynamic> = [name];
			for (p in parts)
				newArr.push(p);
				
			// replace event entry
			selectedEvents[0][1][charter.curEventSelected] = newArr;
			scheduleGridUpdate();
		}
	}
	
	public function scheduleGridUpdate():Void
	{
		if (eventUpdateTimer != null) eventUpdateTimer.cancel();
		eventUpdateTimer = FlxTimer.wait(0.08, function() {
			charter.updateGrid();
			eventUpdateTimer = null;
		});
	}
	
	public function updateEventUI():Void
	{
		var newText = 'No event selected!';
		
		final selectedEvents = charter.getSelectedEvents();
		final singleSelected:Bool = (selectedEvents.length == 1);
		
		final selection:String = (singleSelected ? selectedEvents[0][1][charter.curEventSelected][0] : songDialog.eventDropdown.selectedItem?.id);
		var eventThing:Dynamic = Lambda.find(charter.eventStuff, (e) -> e.name == selection);
		var eventIndex:Int = charter.eventStuff.indexOf(eventThing);
		
		if (singleSelected)
		{
			charter.curEventSelected = Std.int(FlxMath.bound(charter.curEventSelected, 0, selectedEvents[0][1].length - 1));
			
			newText = '${charter.curEventSelected + 1} / ${selectedEvents[0][1].length}';
			
			songDialog.selectedEventStepper.populateList([for (event in cast(selectedEvents[0][1], Array<Dynamic>)) ToolKitUtils.makeSimpleDropDownItem(event[0])]);
			
			songDialog.eventDropdown.pauseEvent('change');
			songDialog.selectedEventStepper.pauseEvent('change');
			
			songDialog.eventDropdown.selectedIndex = eventIndex;
			songDialog.selectedEventStepper.selectedIndex = charter.curEventSelected;
			
			songDialog.eventDropdown.resumeEvent('change', true);
			songDialog.selectedEventStepper.resumeEvent('change', true);
			
			// for some reason the event stepper doesnt update immediately someone help me pleading face pleading face
		}
		else
		{
			newText = '---';
			
			songDialog.selectedEventStepper.populateList([]);
			charter.curEventSelected = songDialog.selectedEventStepper.selectedIndex = 0;
			
			songDialog.eventDescription.text = '';
		}
		
		songDialog.eventSelected.text = newText;
		
		songDialog.removeEventButton.disabled = songDialog.pushEventButton.disabled = (!singleSelected);
		songDialog.value1Field.disabled = songDialog.value2Field.disabled = songDialog.selectedEventStepper.disabled = (!singleSelected);
		
		if (selectedEvents.length < 2)
		{
			songDialog.eventDescription.text = (eventThing == null ? 'No description.' : eventThing.description);
			songDialog.eventDescription.hidden = false;
			
			songDialog.eventName.text = songDialog.eventDropdown.selectedItem?.text;
		}
		else
		{
			songDialog.eventDescription.hidden = true;
			
			songDialog.eventName.text = 'Multiple events selected!';
		}
	}
	
	function updateEventFields(event:Array<Dynamic>):Void
	{
		var searchName:String = StringTools.trim(Std.string(event[0])).toLowerCase().replace(" ", "_");
		var selectedDef:Dynamic = Lambda.find(charter.eventStuff, function(e) {
			if (e == null || e.name == null) return false;
			var defName:String = Std.string(e.name).toLowerCase().replace(" ", "_");
			return defName == searchName || Std.string(e.name).toLowerCase() == StringTools.trim(Std.string(event[0])).toLowerCase();
		});
		
		var container:Box = songDialog.eventValueContainer;
		
		if (container != null)
		{
			container.removeAllComponents();
		}
		
		if (selectedDef != null && (Reflect.hasField(selectedDef, 'valueNums') || (selectedDef.values != null && selectedDef.values.length > 0)))
		{
			songDialog.value1Field.hidden = true;
			songDialog.value2Field.hidden = true;
			songDialog.valueListField.hidden = true;
			container.hidden = false;
			
			var dynamicGrid:haxe.ui.containers.Grid = new haxe.ui.containers.Grid();
			dynamicGrid.percentWidth = 100;
			dynamicGrid.columns = 2;
			container.addComponent(dynamicGrid);
			
			var numValues:Int = 0;
			if (Reflect.hasField(selectedDef, 'valueNums') && Reflect.field(selectedDef, 'valueNums') != null)
			{
				numValues = Std.int(Reflect.field(selectedDef, 'valueNums'));
			}
			else if (selectedDef.values != null)
			{
				numValues = selectedDef.values.length;
			}
			
			for (i in 0...numValues)
			{
				final idx = i;
				var valDef:Dynamic = (selectedDef.values != null && idx < selectedDef.values.length) ? selectedDef.values[idx] : null;
				
				var lbl:Label = new Label();
				lbl.text = (valDef != null && Reflect.hasField(valDef, 'name') ? Reflect.field(valDef, 'name') : 'Value ${idx + 1}') + ':';
				lbl.width = 55;
				lbl.verticalAlign = 'center';
				
				var tf:TextField = new TextField();
				tf.percentWidth = 100;
				tf.horizontalAlign = 'right';
				
				if (event.length > idx + 1 && event[idx + 1] != null && Std.string(event[idx + 1]).length > 0)
				{
					tf.text = Std.string(event[idx + 1]);
				}
				else
				{
					tf.text = (valDef != null && Reflect.hasField(valDef, 'defaultValue') ? Std.string(Reflect.field(valDef, 'defaultValue')) : '');
				}
				
				tf.onChange = function(e) {
					final selectedEvents = charter.getSelectedEvents();
					if (selectedEvents.length != 1 || selectedEvents[0][1][charter.curEventSelected] == null) return;
					
					var activeEvent = selectedEvents[0][1][charter.curEventSelected];
					
					while (activeEvent.length <= idx + 1)
					{
						activeEvent.push('');
					}
					
					activeEvent[idx + 1] = tf.text;
					
					scheduleGridUpdate();
				};
				
				dynamicGrid.addComponent(lbl);
				dynamicGrid.addComponent(tf);
			}
		}
		else
		{
			if (container != null) container.hidden = true;
			songDialog.valueListField.hidden = true;
			songDialog.value1Field.hidden = false;
			songDialog.value2Field.hidden = false;
			
			songDialog.value1Field.text = (event.length > 1 ? Std.string(event[1]) : '');
			songDialog.value2Field.text = (event.length > 2 ? Std.string(event[2]) : '');
		}
	}
	
	function refreshCharacterDropdowns():Void
	{
		var characterList:Array<String> = [];
		
		#if MODS_ALLOWED
		var dir = Paths.listAllFilesInDirectory('data/characters/');
		for (i in Paths.listAllFilesInDirectory('characters/'))
			dir.push(i);
			
		for (file in dir)
		{
			if (file.endsWith('.json') || file.endsWith('.xml'))
			{
				var charToCheck:String = file.withoutDirectory().withoutExtension();
				
				if (!characterList.contains(charToCheck)) characterList.push(charToCheck);
			}
		}
		#else
		characterList = CoolUtil.coolTextFile(Paths.txt('characterList'));
		#end
		
		for (dropdown in [songDialog.bfDropdown, songDialog.dadDropdown, songDialog.gfDropdown])
		{
			dropdown.populateList([for (char in characterList) ToolKitUtils.makeSimpleDropDownItem(char)]);
			dropdown.dataSource.sort(null, ASCENDING);
		}
		
		songDialog.bfDropdown.selectedItem = song.player1;
		songDialog.dadDropdown.selectedItem = song.player2;
		songDialog.gfDropdown.selectedItem = song.gfVersion;
	}
	
	function refreshStageDropdown():Void
	{
		#if MODS_ALLOWED
		var directories:Array<String> = [
			Paths.mods('data/stages/'),
			Paths.mods(Mods.currentModDirectory + '/data/stages/'),
			Paths.getCorePath('data/stages/'),
			
			Paths.mods('stages/'),
			Paths.mods(Mods.currentModDirectory + '/stages/'),
			Paths.getCorePath('stages/')
		];
		for (mod in Mods.globalMods)
		{
			directories.push(Paths.mods('$mod/data/stages/'));
			directories.push(Paths.mods('$mod/stages/'));
		}
		
		var stages:Array<String> = ['stage'];
		#else
		var directories:Array<String> = [Paths.getCorePath('data/stages/'), Paths.getCorePath('stages/')];
		
		var stages:Array<String> = CoolUtil.coolTextFile(Paths.txt('stageList'));
		#end
		
		for (directory in directories)
		{
			if (!FunkinAssets.exists(directory)) continue;
			
			for (file in FunkinAssets.readDirectory(directory))
			{
				if (!FunkinAssets.isDirectory(directory + file) && file.extension() != 'json') continue;
				
				final stage:String = file.withoutExtension();
				
				if (!stages.contains(stage)) stages.push(stage);
			}
		}
		
		songDialog.stageDropdown.populateList([for (stage in stages) ToolKitUtils.makeSimpleDropDownItem(stage)]);
		songDialog.stageDropdown.dataSource.sort(null, ASCENDING);
		songDialog.stageDropdown.selectedItem = song.stage;
	}
	
	function refreshSkinDropdown():Void
	{
		var directories:Array<String> = [
			#if MODS_ALLOWED
			Paths.mods('data/noteskins/'), Paths.mods(Mods.currentModDirectory + '/data/noteskins/'),
			#end
			Paths.getCorePath('data/noteskins/')
		];
		#if MODS_ALLOWED
		for (mod in Mods.globalMods)
			directories.push(Paths.mods('$mod/data/noteskins/'));
		#end
		
		var noteskins:Array<String> = ['default'];
		
		for (directory in directories)
		{
			if (!FunkinAssets.exists(directory)) continue;
			
			for (file in FunkinAssets.readDirectory(directory))
			{
				if (!file.endsWith('.json')) continue;
				
				var skin:String = file.substr(0, file.length - 5);
				
				if (!noteskins.contains(skin)) noteskins.push(skin);
			}
		}
		
		for (dropdown in [songDialog.noteSkinDropdown])
		{
			dropdown.populateList([for (skin in noteskins) ToolKitUtils.makeSimpleDropDownItem(skin)]);
			dropdown.dataSource.sort(null, ASCENDING);
		}
		
		// songDialog.noteSkinDropdown.selectedItem = song.arrowSkin;
		// songDialog.splashSkinDropdown.selectedItem = song.splashSkin;
	}
	
	final snapLeniency:Float = 1.25;
	
	function step(time:Float, mod:Int)
	{
		final quant:Int = ChartEditorState.quantization;
		final beat:Float = Conductor.getBeat(time);
		final step:Float = (1 / (quant / 4));
		
		return Conductor.beatToSeconds((mod < 0 ? Math.ceil : Math.floor)((beat + (step * snapLeniency) * mod) / step) * step);
	}
	
	function strumTimeStep(mod:Int)
	{
		if (charter.curSelectedNotes.length == 0) return;
		
		final quant:Int = ChartEditorState.quantization;
		final step:Float = (1 / (quant / 4));
		
		for (note in charter.curSelectedNotes)
		{
			final beat:Float = Conductor.getBeat(note[0]);
			
			note[0] = Conductor.beatToSeconds((mod < 0 ? Math.ceil : Math.floor)((beat + (step * snapLeniency) * mod) / step) * step);
		}
		
		songDialog.strumTimeStepper.changeSilent(Lambda.fold(charter.curSelectedNotes, (note, r) -> Math.min(note[0], r), Math.POSITIVE_INFINITY));
		
		charter.updateGrid();
	}
	
	function sustainLengthStep(mod:Int)
	{
		final notes = charter.getSelectedNotes();
		
		if (notes.length == 0) return;
		
		final quant:Int = ChartEditorState.quantization;
		final step:Float = (1 / (quant / 4));
		
		for (note in notes)
		{
			if (note[2] == null) continue;
			
			final beat:Float = Conductor.getBeat(note[0] + note[2]);
			
			note[2] = (Conductor.beatToSeconds((mod < 0 ? Math.ceil : Math.floor)((beat + (step * snapLeniency) * mod) / step) * step) - note[0]);
		}
		
		songDialog.sustainLengthStepper.changeSilent(Lambda.fold(notes, (note, r) -> Math.max(note[2], r), 0));
		
		charter.updateGrid();
	}
	
	function changeStrumTime(oldTime:Float, newTime:Float)
	{
		final difference:Float = (newTime - oldTime);
		
		if (charter.curSelectedNotes.length == 0 || difference == 0) return;
		
		for (note in charter.curSelectedNotes)
			note[0] += difference;
			
		charter.updateGrid();
	}
	
	function changeSustainLength(oldLength:Float, newLength:Float)
	{
		final difference:Float = (newLength - oldLength);
		
		if (difference == 0) return;
		
		var changed:Bool = false;
		
		for (note in charter.curSelectedNotes)
		{
			if (note[2] == null) continue;
			
			note[2] = Math.max(note[2] + difference, 0);
			changed = true;
		}
		
		if (changed) charter.updateGrid();
	}
}
