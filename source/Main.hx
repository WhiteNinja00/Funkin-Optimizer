package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite {
	var gameWidth = 640;
	var gameHeight = 480;
	var initialState = MainState;
	var updateFramerate = 60;
	var drawFramerate = 60;
	var skipSplash = true;
	var startFullscreen = false;

	public function new() {
		super();
		
		addChild(new FlxGame(gameWidth, gameHeight, initialState, updateFramerate, drawFramerate, skipSplash, startFullscreen));
	}
}
