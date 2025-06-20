package content.songs.meltdown;

import funkin.objects.BGSprite;

// Utilitários seguros
function safeAddToGroup(group:Dynamic, obj:Dynamic) {
	if (group != null && obj != null && !Reflect.hasField(obj, "destroyed")) group.add(obj);
}
function safeAddToStage(obj:Dynamic) {
	if (obj != null && !Reflect.hasField(obj, "destroyed")) stage.add(obj);
}
function safeSetAlpha(obj:Dynamic, value:Float) {
	if (obj != null && Reflect.hasField(obj, "alpha") && !Reflect.hasField(obj, "destroyed")) obj.alpha = value;
}
function safeSetVisible(obj:Dynamic, value:Bool) {
	if (obj != null && Reflect.hasField(obj, "visible") && !Reflect.hasField(obj, "destroyed")) obj.visible = value;
}
function safeSetZIndex(obj:Dynamic, value:Int) {
	if (obj != null && Reflect.hasField(obj, "zIndex") && !Reflect.hasField(obj, "destroyed")) obj.zIndex = value;
}
function safeUpdateHitbox(obj:Dynamic) {
	if (obj != null && Reflect.hasField(obj, "updateHitbox")) obj.updateHitbox();
}

var cutsceneAssets = new FlxTypedGroup();

function onCreate()
{
	try {
		safeAddToStage(cutsceneAssets);
		safeSetZIndex(cutsceneAssets, 20);

		cliff = new BGSprite(null, 0, 0).loadFromSheet('stage/polus/meltdown/cutscene/bg', 'polus_cliff');
		safeAddToGroup(cutsceneAssets, cliff);
		cliff.scale.set(2, 2);
		safeUpdateHitbox(cliff);

		buildings = new BGSprite(null, cliff.x + (996 * cliff.scale.x / 2), cliff.y + (549 * cliff.scale.y / 2)).loadFromSheet('stage/polus/meltdown/cutscene/bg', 'bg_building');
		buildings.scale.set(cliff.scale.x, cliff.scale.y);
		safeUpdateHitbox(buildings);
		safeAddToGroup(cutsceneAssets, buildings);
		safeSetZIndex(buildings, -2);

		brdige = new BGSprite(null, cliff.x + (1664 * cliff.scale.x / 2), cliff.y + (600 * cliff.scale.y / 2)).loadFromSheet('stage/polus/meltdown/cutscene/bg', 'bridge');
		brdige.scale.set(cliff.scale.x, cliff.scale.y);
		safeUpdateHitbox(brdige);
		safeAddToGroup(cutsceneAssets, brdige);
		safeSetZIndex(brdige, 2);

		lava = new BGSprite(null, cliff.x + (-383 * cliff.scale.x / 2), cliff.y + (2574 * cliff.scale.y / 2)).loadFromSheet('stage/polus/meltdown/cutscene/bg', 'bottom_lava');
		lava.scale.set(cliff.scale.x, cliff.scale.y);
		safeUpdateHitbox(lava);
		safeAddToGroup(cutsceneAssets, lava);
		safeSetZIndex(lava, 2);

		lavaCover = new BGSprite(null, cliff.x + (-386 * cliff.scale.x / 2), cliff.y + (3155 * cliff.scale.y / 2)).loadFromSheet('stage/polus/meltdown/cutscene/bg', 'upper_lava');
		lavaCover.scale.set(cliff.scale.x, cliff.scale.y);
		safeUpdateHitbox(lavaCover);
		safeAddToGroup(cutsceneAssets, lavaCover);
		safeSetZIndex(lavaCover, 99);

		crew = new BGSprite(null, cliff.x + (1060 * cliff.scale.x / 2), cliff.y + (398 * cliff.scale.y / 2)).loadFromSheet('stage/polus/meltdown/cutscene/bg', 'bg_crewmates_fuck..my_butt_hurts');
		crew.scale.set(cliff.scale.x, cliff.scale.y);
		safeUpdateHitbox(crew);
		safeAddToGroup(cutsceneAssets, crew);
		safeSetZIndex(crew, -1);

		lavaSplash = new BGSprite(null, cliff.x + (1700 * cliff.scale.x / 2), cliff.y + (2700 * cliff.scale.y / 2)).loadFromSheet('stage/polus/meltdown/cutscene/lava_splash', 'lava splash');
		if (lavaSplash.animation != null && lavaSplash.animation.curAnim != null) {
			lavaSplash.animation.curAnim.looped = false;
			lavaSplash.animation.pause();
		}
		lavaSplash.scale.set((cliff.scale.x / 2) * 0.9, (cliff.scale.y / 2) * 0.9);
		safeUpdateHitbox(lavaSplash);
		safeSetVisible(lavaSplash, false);
		safeAddToGroup(cutsceneAssets, lavaSplash);
		safeSetZIndex(lavaSplash, 2);
		if (lavaSplash.offset != null) lavaSplash.offset.set(0,300);

		var charOffsetX = 200;
		var charOffsetY = 150;

		pushingBF = new BGSprite(null, cliff.x + (1500 * (cliff.scale.x / 2)) + charOffsetX,
			cliff.y + (300 * (cliff.scale.y / 2)) + charOffsetY).loadSparrowFrames('stage/polus/meltdown/cutscene/bf_meltdown_cutscene');
		pushingBF.scale.set(cliff.scale.x / 2, cliff.scale.y / 2);
		safeUpdateHitbox(pushingBF);
		if (pushingBF.animation != null) {
			pushingBF.animation.addByPrefix('ready', 'bf ready to push', 24, true);
			pushingBF.animation.addByPrefix('push', 'bf push him', 24, false);
			pushingBF.animation.play('ready');
		}
		safeAddToGroup(cutsceneAssets, pushingBF);
		safeSetZIndex(pushingBF, -1);

		impostor = new BGSprite(null, cliff.x + (1625 * cliff.scale.x / 2) + charOffsetX,
			cliff.y + (180 * cliff.scale.y / 2) + charOffsetY).loadSparrowFrames('stage/polus/meltdown/cutscene/red_meltdown_cutscene');
		impostor.scale.set(cliff.scale.x / 2, cliff.scale.y / 2);
		safeUpdateHitbox(impostor);
		if (impostor.animation != null) {
			impostor.animation.addByPrefix('nervous', 'nervous buddy', 24, false);
			impostor.animation.addByPrefix('getPushed', 'nervous getting pushed', 24, false);
			impostor.animation.addByPrefix('thumbsup', 'thumb up', 24, false);
			impostor.animation.addByPrefix('falling', 'falling buddy', 24);
			impostor.animation.play('nervous');
			impostor.animation.pause();
			if (impostor.animation.curAnim != null) impostor.animation.curAnim.curFrame = 0;
			impostor.animation.onFrameChange.add((anim, frame, idx) -> {
				if (impostor.offset != null) impostor.offset.set();
				switch (anim)
				{
					case 'getPushed':
						if (impostor.offset != null) impostor.offset.set(0, 20.5 * 2);
					case 'falling':
						if (impostor.offset != null) impostor.offset.set(-25 * 2, -15 * 2);
					case 'thumbsup':
						if (impostor.offset != null) impostor.offset.set(-65 * 2, 5 * 2);
				}
			});
			impostor.animation.onFinish.add(anim -> {
				switch (anim)
				{
					case 'getPushed':
						impostor.animation.play('falling');
				}
			});
		}
		safeAddToGroup(cutsceneAssets, impostor);
		safeSetZIndex(impostor, -1);

		refreshZ(cutsceneAssets);

		safeSetVisible(cutsceneAssets, false);
	} catch (e:Dynamic) {
		NativeAPI.showMessageBox("Cutscene MeltDown Error", "An error occurred during onCreate function:\n" + Std.string(e));
	}
}

function onUpdatePost(e)
{
	if (FlxG.keys.justPressed.G)
	{
		// push();
		// impostor2.visible = !impostor2.visible;
		// trace(impostor2.visible);
		// onEvent('', 'showEnd', '');
		// setSongTime(163099);
	}
	// FlxG.camera.zoom = 0.3;
	// isCameraOnForcedPos = true;
	// FlxG.camera.target = impostor;
}

function push()
{
	try {
		FlxG.camera.zoom += 0.05;
		FlxTween.tween(FlxG.camera, {zoom: 0.5},0.1, {ease: FlxEase.sineOut});

		if (pushingBF != null && pushingBF.animation != null)
			pushingBF.animation.play('push');
		if (impostor != null && impostor.animation != null)
			impostor.animation.play('getPushed');
		safeSetZIndex(impostor, 3);
		refreshZ(cutsceneAssets);

		var sc = impostor != null && impostor.scale != null ? impostor.scale.x : 1;

		FlxTween.tween(impostor, {y: impostor.y - 50}, 0.2,
			{
				ease: FlxEase.sineOut,
				onComplete: Void -> {
					FlxTween.tween(impostor, {y: lavaSplash.y + impostor.frameHeight + 300}, 2, {ease: FlxEase.sineIn, onComplete: splash});
					FlxTween.tween(impostor.scale, {x: sc * 1.7, y: sc * 1.7}, 1, {ease: FlxEase.sineOut,onComplete: Void->{
						FlxTween.tween(impostor.scale, {x: sc * 1.3,y: sc * 1.3}, 1, {ease: FlxEase.sineIn});
					}});
				}
			});
		FlxTween.tween(impostor, {x: impostor.x + 80}, 0.4,
			{
				ease: FlxEase.sineOut,
				onComplete: Void -> {
					FlxTween.tween(impostor, {x: impostor.x - 80}, 1, {ease: FlxEase.sineIn, startDelay: 0.5});
				}
			});
		FlxTween.tween(camFollow, {y: camFollow.y - 25},0.2,{onComplete: Void->{
			FlxTween.tween(camFollow, {y: lavaSplash.y + 300},1.2);
			FlxTween.tween(FlxG.camera, {zoom: 0.35},1.2);
		}});
	} catch (e:Dynamic) {
		NativeAPI.showMessageBox("Cutscene MeltDown Error", "An error occurred during push function:\n" + Std.string(e));
	}
}

function splash()
{
	try {
		FlxTween.cancelTweensOf(impostor, ['scale.x', 'scale.y', 'y', 'x']);
		if (lavaSplash != null && lavaSplash.animation != null) {
			lavaSplash.animation.resume();
			lavaSplash.visible = true;
		}
		if (impostor != null && impostor.animation != null) {
			impostor.animation.play('thumbsup');
			impostor.visible = false;
		}
	} catch (e:Dynamic) {
		NativeAPI.showMessageBox("Cutscene MeltDown Error", "An error occurred during splash function:\n" + Std.string(e));
	}
}

function onEvent(ev, v1, v2)
{
	try {
		switch (ev)
		{
			case '':
				switch (v1)
				{
					case 'redTurn':
						if (impostor != null && impostor.animation != null)
							impostor.animation.play('nervous',true);

					case 'hideGame':
						FlxG.camera._fxFadeColor = FlxColor.BLACK;
						FlxTween.tween(FlxG.camera, {_fxFadeAlpha: 1}, 0.5);
						FlxTween.tween(camHUD, {alpha: 0}, 0.5);
						var snowEmitter = global.get('snowEmitter');
						if (snowEmitter != null) {
							if (Reflect.hasField(snowEmitter, "speed")) snowEmitter.speed.set(700,900);
							snowEmitter.frequency = 0.07;
						}
						canReset = false;
					case 'hideGame2':
						FlxTween.tween(FlxG.camera, {_fxFadeAlpha: 1}, 2);
					case 'showEnd':
						safeSetVisible(dadGroup, false);
						safeSetVisible(boyfriendGroup, false);
						safeSetVisible(gfGroup, false);

						stage.forEachOfType(BGSprite,(f->{
							safeSetAlpha(f, 0);
						}));

						safeSetVisible(cutsceneAssets, true);

						if (global.get('redVoters') != null) safeSetVisible(global.get('redVoters'), false);
						if (global.get('bfVoters') != null) safeSetVisible(global.get('bfVoters'), false);

						if (global.get('base_bg') != null) {
							safeSetAlpha(global.get('base_bg'), 1);
							safeSetZIndex(global.get('base_bg'), 18);
						}
						if (global.get('base_stars') != null) {
							safeSetZIndex(global.get('base_stars'), 18);
							safeSetAlpha(global.get('base_stars'), 1);
						}
						
						var snowEmitter = global.get('snowEmitter');
						if (snowEmitter != null) {
							stage.remove(snowEmitter);
							safeAddToGroup(cutsceneAssets, snowEmitter);
							safeSetZIndex(snowEmitter, -2);
						}
						
						refreshZ();
						refreshZ(cutsceneAssets);
						
						isCameraOnForcedPos = true;
						snapCamFollowToPos(cliff.x + 2000, cliff.y + 300);
						
						FlxG.camera._fxFadeAlpha = 1;
						FlxG.camera._fxFadeColor = FlxColor.BLACK;
						FlxTween.tween(FlxG.camera, {_fxFadeAlpha: 0}, 0.5);
						
						FlxTween.tween(camFollow, {y: cliff.y + 400}, 1, {ease: FlxEase.sineOut});
						
						camZooming = false;
						FlxG.camera.zoom = 0.5;
						defaultCamZoom = 0.5;

					case 'push': push();
			}
		}
	} catch (e:Dynamic) {
		NativeAPI.showMessageBox("Cutscene MeltDown Error", "An error occurred during onEvent function:\n" + Std.string(e));
	}
}