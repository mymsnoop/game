package 
{	
	import flash.display.MovieClip;
	import flash.net.*;
	import flash.events.*;
	import com.greensock.TweenLite;
	import com.adobe.serialization.json.*;
	import com.greensock.easing.*;
	
	/**
	 * ...
	 * @author Karan Chhabra...
	 */
	public class  Player extends MovieClip
	{
		public var id:Number;
		public var unit:Unit;
		public var remoteX:Number = 0;
		public var remoteY:Number = 0;
		public var ms:Number;
		public var hp:Number;
		public var regen:Number;
		
		public function Player() {
			this.unit = new Unit();
		}
		
	}
	
}