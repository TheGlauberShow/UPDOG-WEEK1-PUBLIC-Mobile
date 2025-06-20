import flixel.addons.transition.FlxTransitionableState;

var singAnimations = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
var bfStar:Character;
var redStar:Character;
var orange:BGSprite;
var green:BGSprite;
var redCutscene:BGSprite;
var gunshot:BGSprite;

import mobile.scripting.NativeAPI;

global.set('ignoreCountdown',true);

function safeSetAlpha(obj:Dynamic, value:Float) {
    if (obj != null && Reflect.hasField(obj, "alpha") && !Reflect.hasField(obj, "destroyed")) {
        obj.alpha = value;
    }
}

function safeAddToStage(obj:Dynamic) {
    if (obj != null && !Reflect.hasField(obj, "destroyed")) {
        stage.add(obj);
    }
}

function onCreate()
{
    try {
        bfStar = new Character(1500, -1150, 'bfStar', false);
        if (bfStar != null) {
            bfStar.flipX = false;
            bfStar.scrollFactor.set(1.2, 1.2);
            safeSetAlpha(bfStar, 0);
            bfStar.zIndex = 1;
            safeAddToStage(bfStar);
            global.set('bfStar', bfStar);
        }

        redStar = new Character(-100, -1200, 'redStar', false);
        if (redStar != null) {
            redStar.flipX = false;
            redStar.scrollFactor.set(1.2, 1.2);
            safeSetAlpha(redStar, 0);
            redStar.zIndex = 1;
            safeAddToStage(redStar);
            global.set('redStar', redStar);
        }

        orange = new BGSprite(null, -800, 440).loadSparrowFrames('stage/polus/orange');
        if (orange != null) {
            orange.animation.addByPrefix('idle', 'orange_idle instance 1', 24, true);
            orange.animation.addByPrefix('wave', 'wave instance 1', 24, true);
            orange.animation.addByPrefix('walk', 'frolicking instance 1', 24, true);
            orange.animation.addByPrefix('die', 'death instance 1', 24, false);
            orange.animation.play('walk');
            orange.scale.set(0.8, 0.8);
            safeSetAlpha(orange, 0);
            orange.zIndex = 4;
            safeAddToStage(orange);
        }
        
        green = new BGSprite(null, -800, 450).loadSparrowFrames('stage/polus/orange');
        if (green != null) {
            green.animation.addByPrefix('idle', 'stand instance 1', 24, true);
            green.animation.addByPrefix('kill', 'kill instance 1', 24, false);
            green.animation.addByPrefix('walk', 'sneak instance 1', 24, true);
            green.animation.addByPrefix('carry', 'pulling instance 1', 24, true);
            green.animation.play('walk');
            green.scale.set(0.8, 0.8);
            safeSetAlpha(green, 0);
            green.zIndex = 4;
            safeAddToStage(green);
        }

        if(PlayState.isStoryMode)
        {
            redCutscene = new BGSprite(null, dad.x - 5, dad.y).loadSparrowFrames('stage/polus/sabotagecutscene/redCutscene');
            if (redCutscene != null) {
                redCutscene.animation.addByPrefix('mad', 'red mad0', 24, false);
                redCutscene.scale.set(0.9, 0.9);
                redCutscene.animation.play('mad');
                redCutscene.visible = false;
                redCutscene.zIndex = 6;
                safeAddToStage(redCutscene);
            }

            gunshot = new BGSprite(null, redCutscene != null ? redCutscene.x + 515 : 0, redCutscene != null ? redCutscene.y + 90 : 0)
                .loadSparrowFrames('stage/polus/sabotagecutscene/gunshot');
            if (gunshot != null) {
                gunshot.animation.addByPrefix('shot', 'stupid impact0', 24, false);
                gunshot.scale.set(0.9, 0.9);
                gunshot.visible = false;
                gunshot.zIndex = 2000;
                safeAddToStage(gunshot);
            }

            songEndCallback = sabotageCutscene1stHalf;
        }

        global.set('sussus_green', green);
        global.set('sussus_orange', orange);
    } catch (e:Dynamic) {
        NativeAPI.showMessageBox("Event Script Error", "An error occurred during onCreate function:\n" + Std.string(e));
    }
}

function onBeatHit()
{
    try {
        if (bfStar != null && bfStar.animation != null && bfStar.animation.curAnim != null) {
            var anim = bfStar.animation.curAnim.name;
            if (!StringTools.contains(anim, 'sing') && game.curBeat % 2 == 0) bfStar.dance();
        }
    
        if (redStar != null && redStar.animation != null && redStar.animation.curAnim != null) {
            var anim2 = redStar.animation.curAnim.name;
            if (!StringTools.contains(anim2, 'sing') && game.curBeat % 2 == 0) redStar.dance();
        }
    } catch (e:Dynamic) {
        NativeAPI.showMessageBox("Event Script Error", "An error occurred during onBeatHit function:\n" + Std.string(e));
    }
}

function opponentNoteHit(note)
{
    try {
        if (redStar != null && Reflect.hasField(redStar, "alpha") && redStar.alpha != 0.0)
        {
            redStar.playAnim(singAnimations[note.noteData], true);
            redStar.holdTimer = 0;
        }
    } catch (e:Dynamic) {
        NativeAPI.showMessageBox("Event Script Error", "An error occurred during opponentNoteHit function:\n" + Std.string(e));
    }
}

function goodNoteHit(note)
{
    try {
        if (bfStar != null && Reflect.hasField(bfStar, "alpha") && bfStar.alpha != 0.0)
        {
            bfStar.playAnim(singAnimations[note.noteData], true);
            bfStar.holdTimer = 0;
        }
    } catch (e:Dynamic) {
        NativeAPI.showMessageBox("Event Script Error", "An error occurred during goodNoteHit function:\n" + Std.string(e));
    }
}

function sabotageCutscene1stHalf()
{
    try {
        isCameraOnForcedPos = true;
        camZooming = false;
        dadGroup.visible = false;
        if (redCutscene != null) redCutscene.visible = true;
        FlxTween.tween(camFollow, {x: 1025, y: 500}, 2, {ease: FlxEase.expoOut});
        FlxTween.tween(FlxG.camera, {zoom: 0.65}, 2, {ease: FlxEase.expoOut});
        FlxTween.tween(camHUD, {alpha: 0}, 0.75, {ease: FlxEase.expoOut});
        FlxG.sound.play(Paths.sound('moogusCutscene'), 1);
        if (redCutscene != null) redCutscene.animation.play('mad');
        if (redCutscene != null && redCutscene.animation != null)
        redCutscene.animation.onFinish.add((mad)->{
            var blackSprite = global.get('blackSprite');
            if (blackSprite != null && Reflect.hasField(blackSprite, "alpha")) {
                blackSprite.alpha = 1;
                blackSprite.cameras = [camGame];
                blackSprite.zIndex = 1900;
                if (Reflect.hasField(blackSprite, "scale")) blackSprite.scale.set(3000, 2000);
                refreshZ();
            }
            if (gunshot != null) {
                gunshot.visible = true;
                gunshot.animation.play('shot');
                if (gunshot.animation != null)
                gunshot.animation.onFinish.add((mad)->{
                    gunshot.visible = false;
                });
            }
            new FlxTimer().start(2, function(tmr:FlxTimer) {
                endSong();
                FlxTransitionableState.skipNextTransOut = true;
            });
        });
    } catch (e:Dynamic) {
        NativeAPI.showMessageBox("Event Script Error", "An error occurred during sabotageCutscene1stHalf function:\n" + Std.string(e));
    }
}