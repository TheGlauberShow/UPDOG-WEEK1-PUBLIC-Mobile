import flixel.ui.FlxBar;
import flixel.text.FlxText;
import flixel.addons.transition.FlxTransitionableState;

var singAnimations = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
var redCutscene:BGSprite;
var bfCutscene:BGSprite;
var shield:BGSprite;
var shieldBreakTop:BGSprite;
var shieldBreakBottom:BGSprite;
var invertMask:BGSprite;
var orangeGhost:BGSprite;
var boomBoxS:BGSprite;
var bfCutOffsets:Map<String, Array<Float>> = [
	'covered-grey' => [0, 0],
	'covered' => [1, -2],
	'uncover' => [1, 5],
	'awkward' => [4, 2],
	'trans' => [6, 35]
];
var anotherBlackSprite:FlxSprite;
var devCutscene:Bool = false;

var detective:Bool = false;

import Reflect;
import mobile.scripting.NativeAPI;

// Funções utilitárias para checagem segura
function safeSetAlpha(obj:Dynamic, value:Float) {
	if (obj != null && Reflect.hasField(obj, "alpha") && !Reflect.hasField(obj, "destroyed")) obj.alpha = value;
}
function safeSetVisible(obj:Dynamic, value:Bool) {
	if (obj != null && Reflect.hasField(obj, "visible") && !Reflect.hasField(obj, "destroyed")) obj.visible = value;
}
function safeSetZIndex(obj:Dynamic, value:Int) {
	if (obj != null && Reflect.hasField(obj, "zIndex") && !Reflect.hasField(obj, "destroyed")) obj.zIndex = value;
}
function safeAddToStage(obj:Dynamic) {
	if (obj != null && !Reflect.hasField(obj, "destroyed")) stage.add(obj);
}
function safeInsertGame(obj:Dynamic, idx:Int) {
	if (obj != null) game.insert(idx, obj);
}

function startInvestigationCountdown(seconds:Int)
{
	try {
		var countdown = {value: seconds};
		if (investigationText != null)
			investigationText.text = "Investigation ends in " + countdown.value;
		var countdownTimer:FlxTimer = new FlxTimer();
		countdownTimer.start(1, function(timer:FlxTimer) {
			countdown.value--;
			if (investigationText != null) {
				if (countdown.value >= 0)
					investigationText.text = "Investigation ends in " + countdown.value;
				else
					investigationText.text = "Investigation complete!";
			}
		}, seconds + 1);
	} catch (e:Dynamic) {
		NativeAPI.showMessageBox("Sabotage Song Error", "An error occurred during on startInvestigationCountdown function:\n" + Std.string(e));
	}
}

function onCreate()
{
	try {
		if(devCutscene || (PlayState.isStoryMode && !PlayState.seenCutscene))
		{
			songStartCallback = sabotageCutscene2ndHalf;
			Paths.sound('sabotageCutscene');

			bfCutscene = new BGSprite(null, boyfriend.x + 10, boyfriend.y + 25).loadSparrowFrames('stage/polus/sabotagecutscene/bfCutscene');
			if (bfCutscene != null && bfCutscene.animation != null) {
				bfCutscene.animation.addByPrefix('covered-grey', 'boyfriend gray covered0', 24, false);
				bfCutscene.animation.addByPrefix('trans', 'boyfriend ready', 24, false);
				bfCutscene.animation.addByPrefix('awkward', 'boyfriend awkward', 24, false);
				bfCutscene.animation.addByPrefix('covered', 'boyfriend covered0', 24, true);
				bfCutscene.animation.addByPrefix('uncover', 'boyfriend uncover0', 24, false);
				bfCutscene.animation.addByIndices('uncoverLoop', 'boyfriend uncover', [for (i in 16 ... 28) i], '', 24);
				bfCutscene.animation.finishCallback = (ani:String) -> {
					if (ani == 'uncover')
						bfCutscene.animation.play('uncoverLoop', true);
				};
			}
			bfCutscene.scale.set(1.1, 1.1);
			bfCutscene.zIndex = 1950;
			safeAddToStage(bfCutscene);

			orangeGhost = new BGSprite(null, 1040, 210).loadSparrowFrames('stage/polus/sabotagecutscene/ghostOrange');
			if (orangeGhost != null && orangeGhost.animation != null)
				orangeGhost.animation.addByPrefix('ghost', 'ghost orange0', 24, false);
			safeSetAlpha(orangeGhost, 0);
			orangeGhost.zIndex = 12;
			safeAddToStage(orangeGhost);

			shield = new BGSprite(null, bfCutscene.x - 115, bfCutscene.y - 40).loadSparrowFrames('stage/polus/sabotagecutscene/shield');
			if (shield != null && shield.animation != null)
				shield.animation.addByPrefix('break', 'shield breaks0', 24, false);
			shield.scale.set(1.1, 1.1);
			shield.zIndex = 2000;
			shield.blend = 0;
			safeAddToStage(shield);

			shieldBreakBottom = new BGSprite(null, shield.x - 25, shield.y - 50).loadSparrowFrames('stage/polus/sabotagecutscene/shield');
			if (shieldBreakBottom != null && shieldBreakBottom.animation != null)
				shieldBreakBottom.animation.addByPrefix('shatter', 'shield shatter bottom0', 24, false);
			shieldBreakBottom.scale.set(1.1, 1.1);
			shieldBreakBottom.visible = false;
			shieldBreakBottom.zIndex = 12;
			shieldBreakBottom.blend = 0;
			safeAddToStage(shieldBreakBottom);

			shieldBreakTop = new BGSprite(null, shield.x - 75, shield.y - 100).loadSparrowFrames('stage/polus/sabotagecutscene/shield');
			if (shieldBreakTop != null && shieldBreakTop.animation != null)
				shieldBreakTop.animation.addByPrefix('shatter', 'shield shatter top0', 24, false);
			shieldBreakTop.scale.set(1.1, 1.1);
			shieldBreakTop.visible = false;
			shieldBreakTop.zIndex = 2000;
			shieldBreakTop.blend = 0;
			safeAddToStage(shieldBreakTop);

			invertMask = new BGSprite(null, shield.x - 300, shield.y - 325).loadSparrowFrames('stage/polus/sabotagecutscene/tempshieldthing');
			if (invertMask != null && invertMask.animation != null)
				invertMask.animation.addByPrefix('glow', 'temp0', 24, false);
			invertMask.scale.set(1.1, 1.1);
			invertMask.blend = 0;
			invertMask.zIndex = 2000;
			invertMask.visible = false;
			safeAddToStage(invertMask);

			redCutscene = new BGSprite(null, dad.x - 10, dad.y - 7).loadSparrowFrames('stage/polus/sabotagecutscene/redCutscene');
			if (redCutscene != null && redCutscene.animation != null) {
				redCutscene.animation.addByPrefix('awky', 'red AWKWARD0', 24, false);
				redCutscene.animation.addByIndices('idle', 'red AWKWARD0', [0], "", 24, false);
				redCutscene.animation.addByPrefix('trans', 'red transition back', 24, false);
			}
			redCutscene.scale.set(0.9, 0.9);
			redCutscene.zIndex = 6;
			safeAddToStage(redCutscene);

			anotherBlackSprite = new FlxSprite(600, 0).makeScaledGraphic(3000, 2000, 0xff000000);
			anotherBlackSprite.zIndex = 2020;
			safeAddToStage(anotherBlackSprite);
		}
	
		boomBoxS = new BGSprite().loadSparrowFrames('stage/polus/meltdown/boomboxfall');
		if (boomBoxS != null && boomBoxS.animation != null)
			boomBoxS.animation.addByPrefix('anim', 'boombox falls', 24, false);
		boomBoxS.zIndex = gfGroup != null ? gfGroup.zIndex + 10 : 10;
		boomBoxS.scale.set(1.1, 1.1);
		safeSetAlpha(boomBoxS, .001);
		global.set('boomBoxS', boomBoxS);

		global.set('startInvestigationCountdown', startInvestigationCountdown);

		saboDetective = new Character(2540, 81, 'detectiveSabotage', false);
		if (saboDetective != null) {
			safeSetAlpha(saboDetective, 0);
			saboDetective.flipX = false;
			saboDetective.zIndex = 3;
			safeAddToStage(saboDetective);
			global.set('sabo_detective', saboDetective);
		}

		var struct = {};

		detectiveIcon = new BGSprite("stage/polus/detective", 90, 1000);
		if (detectiveIcon != null) {
			detectiveIcon.scale.set(0.65, 0.65);
			safeInsertGame(detectiveIcon, members.indexOf(playHUD));
			detectiveIcon.cameras = [game.camHUD];
			struct.detectiveIcon = detectiveIcon;
		}

		detectiveUI2 = new BGSprite("stage/polus/inside", -160, 1000);
		if (detectiveUI2 != null) {
			detectiveUI2.scale.set(0.6, 0.6);
			safeInsertGame(detectiveUI2, members.indexOf(playHUD));
			detectiveUI2.cameras = [game.camHUD];
			struct.detectiveUI2 = detectiveUI2;
		}

		flxBar = new FlxBar(270, 560, FlxBarFillDirection.LEFT_TO_RIGHT, 290, 45, null, null, 0, 60, true);
		if (flxBar != null) {
			flxBar.createFilledBar(0xff000000, 0xFF62E0CF, true);
			flxBar.setParent(null, "x", "y", true);
			flxBar.percent = 0;
			flxBar.scale.set(1.3, 1.3);
			if (flxBar != null) flxBar.alpha = 0;
			flxBar.cameras = [game.camHUD];
			safeInsertGame(flxBar, members.indexOf(playHUD));
			struct.flxBar = flxBar;
		}

		detectiveUI = new BGSprite('stage/polus/frame', -160, 1000);
		if (detectiveUI != null) {
			detectiveUI.scale.set(0.6, 0.6);
			detectiveUI.cameras = [game.camHUD];
			safeInsertGame(detectiveUI, members.indexOf(playHUD));
			struct.detectiveUI = detectiveUI;
		}

		investigationText = new FlxText(180, 1000, 480, "Investigation ends in 0", true);
		if (investigationText != null) {
			investigationText.setFormat(Paths.font("bahn"), 24, 0xFFFFFF, "center");
			investigationText.cameras = [game.camHUD];
			if (investigationText != null) investigationText.alpha = 1;
			investigationText.antialiasing = ClientPrefs.globalAntialiasing;
			safeInsertGame(investigationText, members.indexOf(playHUD));
			struct.investigationText = investigationText;
		}
	
		applebar = new BGSprite("stage/polus/saboSpotlight", 2250, -350);
		if (applebar != null) {
			safeSetAlpha(applebar, 0);
			applebar.blend = 0;
			applebar.zIndex = 15;
			safeAddToStage(applebar);
			global.set('sabo_spotlight', applebar);
		}
	
		global.set('detectiveUI', struct);
	} catch (e:Dynamic) {
		NativeAPI.showMessageBox("Sabotage Song Error", "An error occurred during onCreate function:\n" + Std.string(e));
	}
}

function updateDetectiveIcon(elapsed:Float)
{
	try {
		if (detectiveIcon != null && detectiveIcon.scale != null) {
			var mult:Float = FlxMath.lerp(0.7, detectiveIcon.scale.x, Math.exp(-elapsed * 9));
			detectiveIcon.scale.set(mult, mult);
		}
	} catch (e:Dynamic) {
		NativeAPI.showMessageBox("Sabotage Song Error", "An error occurred during on updateDetectiveIcon function:\n" + Std.string(e));
	}
}

function onBeatHit()
{
	try {
		if (detectiveIcon != null) {
			detectiveIcon.scale.set(0.65, 0.65);
			detectiveIcon.updateHitbox();
			updateDetectiveIcon(FlxG.elapsed);
		}
		if (saboDetective != null && saboDetective.animation != null && saboDetective.animation.curAnim != null) {
			var anim = saboDetective.animation.curAnim.name;
			if (!StringTools.contains(anim, 'sing') && game.curBeat % 2 == 0) saboDetective.dance();
		}
	} catch (e:Dynamic) {
		NativeAPI.showMessageBox("Sabotage Song Error", "An error occurred during onBeatHit function:\n" + Std.string(e));
	}
}

function onUpdatePost(e)
{
	if (devCutscene && FlxG.keys.justPressed.F5)
		FlxG.resetState();
	updateDetectiveIcon(e);
}

function goodNoteHit(note)
{
	try {
		if (saboDetective != null) {
			saboDetective.playAnim(singAnimations[note.noteData], true);
			saboDetective.holdTimer = 0;
		}
	} catch (e:Dynamic) {
		NativeAPI.showMessageBox("Sabotage Song Error", "An error occurred during goodNoteHit function:\n" + Std.string(e));
	}
}

var testTimer:FlxTimer;

function sabotageCutscene2ndHalf()
{
	try {
		testTimer = new FlxTimer().start((0.825), function(tmr:FlxTimer) {
			if (gf != null
				&& tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0
				&& gf.animation != null && gf.animation.curAnim != null)
			{
				gf.dance();
			}
		}, 20);

		new FlxTimer().start(0.125, function(tmr:FlxTimer) {
			FlxG.sound.play(Paths.sound('sabotageCutscene'), 1);
		});

		var blackSprite = global.get('blackSprite');
		if (blackSprite != null && Reflect.hasField(blackSprite, "alpha")) {
			if (blackSprite != null) blackSprite.alpha = 1;
			blackSprite.cameras = [camGame];
			blackSprite.zIndex = 1900;
			if (Reflect.hasField(blackSprite, "scale")) blackSprite.scale.set(3000, 2000);
			blackSprite.x += 300;
			refreshZ();
		}

		if (anotherBlackSprite != null)
			FlxTween.tween(anotherBlackSprite, {alpha:0}, 3, {ease: FlxEase.expoOut});

		if (boyfriend != null) boyfriend.visible = false;
		if (dad != null) dad.visible = false;
		if (redCutscene != null && redCutscene.animation != null)
			redCutscene.animation.play('idle');

		isCameraOnForcedPos = true;
		camZooming = false;

		camFollow.set(1400, 685);
		camFollowPos.setPosition(1400, 685);
		FlxTween.tween(camFollow, {x: 1490, y: 685}, 0.5, {ease: FlxEase.expoIn});
		FlxG.camera.zoom = 1;
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, 0.75, {ease: FlxEase.expoIn, onComplete: function(twn:FlxTween)
		{
			FlxTween.tween(FlxG.camera, {zoom: 1.25}, 0.75, {ease: FlxEase.expoOut, onComplete: function(twn:FlxTween)
			{
				FlxTween.tween(FlxG.camera, {zoom: 1.3}, 1, {ease: FlxEase.expoOut});
				FlxTween.tween(camFollow, {x: 1500, y: 685}, 1, {ease: FlxEase.expoOut});
			}});
		}});

		if (camHUD != null) camHUD.alpha = 0;
		if (shield != null && shield.animation != null) shield.animation.play('break');
		if (bfCutscene != null && bfCutscene.animation != null) {
			bfCutscene.animation.play('covered-grey');
			if (bfCutOffsets.exists('covered-grey')) bfCutscene.offset.set(bfCutOffsets['covered-grey'][0], bfCutOffsets['covered-grey'][1]);
		}

		new FlxTimer().start(2.75, function(tmr:FlxTimer) {
			camGame.shake(0.00075, .5);
			if (invertMask != null) {
				invertMask.visible = true;
				if (invertMask.animation != null) {
					invertMask.animation.play('glow');
					invertMask.animation.pause();
				}
				if (invertMask != null) invertMask.alpha = 0;
				invertMask.scale.set(1.5, 1.5);
				FlxTween.tween(invertMask, {alpha: 1, 'scale.x': .6, 'scale.y': .6}, .5, {ease: FlxEase.quadIn});
			}
			new FlxTimer().start(0.5, function(tmr:FlxTimer) {
				if (blackSprite != null) {
					blackSprite.visible = false;
					blackSprite.x -= 300;
				}
				if (shield != null) shield.visible = false;
				if (bfCutscene != null && bfCutscene.animation != null) {
					bfCutscene.animation.play('covered');
					if (bfCutOffsets.exists('covered')) bfCutscene.offset.set(bfCutOffsets['covered'][0], bfCutOffsets['covered'][1]);
					bfCutscene.zIndex = 12;
				}
				for(i in [shieldBreakTop, shieldBreakBottom])
				{
					if (i != null && i.animation != null) {
						i.animation.play('shatter');
						i.visible = true;
						i.animation.onFinish.add((anim)->{
							i.visible = false;
						});
					}
				}
				if (invertMask != null && invertMask.animation != null) {
					invertMask.visible = true;
					invertMask.animation.resume();
					invertMask.animation.onFinish.add((anim)->{
						invertMask.visible = false;
					});
				}
				refreshZ();
				camGame.shake(0.006, .5);
				if (invertMask != null)
					FlxTween.tween(invertMask.scale, {x: 1.5, y: 1.5}, .75, {ease: FlxEase.quadOut});
				FlxTween.tween(FlxG.camera, {zoom: 0.9}, 1.3, {ease: FlxEase.expoOut});
				FlxTween.tween(camFollow, {x: 1445, y: 665}, 1.3, {ease: FlxEase.expoOut});
				new FlxTimer().start(0.3, function(tmr:FlxTimer) {
					if (orangeGhost != null && orangeGhost.animation != null) {
						orangeGhost.animation.play('ghost');
						orangeGhost.visible = true;
						FlxTween.tween(orangeGhost, {x:1000, y:250, alpha: 0.5}, 3, {ease: FlxEase.expoOut});
					}
				});
				new FlxTimer().start(4.5, function(tmr:FlxTimer) {
					if (orangeGhost != null)
						FlxTween.tween(orangeGhost, {alpha: 0}, 0.75, {ease: FlxEase.expoOut});
				});
			});
		});

		new FlxTimer().start(7.5, function(tmr:FlxTimer) {
			FlxTween.tween(camFollow, {x: 620, y: 670}, 2.3, {ease: FlxEase.quadInOut, startDelay: 0.1});
			FlxTween.tween(FlxG.camera, {zoom: 0.85}, 2.3, {ease: FlxEase.quadInOut, startDelay: 0.1});
		});

		new FlxTimer().start(8.3, function(tmr:FlxTimer) {
			if (bfCutscene != null && bfCutscene.animation != null) {
				bfCutscene.animation.play('uncover');
				if (bfCutOffsets.exists('uncover')) bfCutscene.offset.set(bfCutOffsets['uncover'][0], bfCutOffsets['uncover'][1]);
			}
		});

		new FlxTimer().start(9, function(tmr:FlxTimer) {
			if (redCutscene != null && redCutscene.animation != null)
				redCutscene.animation.play('awky');
		});

		new FlxTimer().start(11.3, function(tmr:FlxTimer) {
			if (bfCutscene != null && bfCutscene.animation != null) {
				bfCutscene.animation.play('awkward');
				if (bfCutOffsets.exists('awkward')) bfCutscene.offset.set(bfCutOffsets['awkward'][0], bfCutOffsets['awkward'][1]);
			}
			FlxTween.tween(camFollow, {y: 560}, 1.75, {ease: FlxEase.quadInOut});
			FlxTween.tween(camFollow, {x: 850}, 1.75, {ease: FlxEase.sineInOut});
			FlxTween.tween(FlxG.camera, {zoom: 0.65}, 1.75, {ease: FlxEase.quadInOut});
		});

		new FlxTimer().start(14, function(tmr:FlxTimer) {
			FlxTween.tween(camFollow, {x: 1025, y: 500}, 1.5, {ease: FlxEase.quadOut});
			FlxTween.tween(FlxG.camera, {zoom: 0.5}, 1.5, {ease: FlxEase.sineOut});
		});

		new FlxTimer().start(15.75, function(tmr:FlxTimer) {
			if (redCutscene != null && redCutscene.animation != null)
				redCutscene.animation.play('trans');
			if (bfCutscene != null && bfCutscene.animation != null) {
				bfCutscene.animation.play('trans');
				if (bfCutOffsets.exists('trans')) bfCutscene.offset.set(bfCutOffsets['trans'][0], bfCutOffsets['trans'][1]);
			}
			if (redCutscene != null) redCutscene.offset.set(5, -6);
		});

		new FlxTimer().start(16.5, function(tmr:FlxTimer) {
			startCountdown();
			if (bfCutscene != null) bfCutscene.visible = false;
			if (redCutscene != null) redCutscene.visible = false;
			if (boyfriend != null) boyfriend.visible = true;
			if (dad != null) dad.visible = true;
			isCameraOnForcedPos = false;
			FlxTween.tween(camHUD, {alpha: 1}, 0.75, {ease: FlxEase.expoOut, startDelay: 0.25});
			PlayState.seenCutscene = true;
			FlxTransitionableState.skipNextTransOut = false;
		});
	} catch (e:Dynamic) {
		NativeAPI.showMessageBox("Sabotage Song Error", "An error occurred during on sabotageCutscene2ndHalf function:\n" + Std.string(e));
	}
}

function onDestroy()
{
	FlxTransitionableState.skipNextTransOut = false;
}