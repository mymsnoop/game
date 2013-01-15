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
	public class  Ammo extends MovieClip
	{
		public var id:Number;
		public var unit:MovieClip;
		public var remoteX:Number = -1;
		public var remoteY:Number = -1;
		public var ms:Number;
		
		public function Ammo(type:int = 0) {
			if (type == 0)
				this.unit = new Missile();
			else if (type == 1)
				this.unit = new Homing();
				/*
			else if (type == 2)
				//this.unit = new ;
			else if (type == 3)
				//this.unit = new ;
			else if (type == 4)
				//this.unit = new ;
			else if (type == 5)
				//this.unit = new ;
				*/
		}
	}
	
}