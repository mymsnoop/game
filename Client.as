﻿package  {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Matrix;
	import flash.net.*;
	import flash.events.*;
	import com.greensock.TweenMax;
	import com.greensock.plugins.*;
	import com.adobe.serialization.json.*;
	import com.greensock.easing.*;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	import flash.display.Graphics;
	import flash.text.*;
	
	TweenPlugin.activate([BlurFilterPlugin]);
	/**
	 * ...
	 * @author Karan Chhabra...
	 */
	
	public class Client extends MovieClip {
		public var SPEED:Number = 100; //pixels per second
		public var myIndex:int = -1;
		public var lastClicked:Object = { };
		public var players:Array = new Array();
		public var ammo:Array = new Array();
		public var extrapolationTime:Number = 0.2;
		public var crossHair:Crosshair = new Crosshair();
		public var weapon:int = -1;
		public var fadetime:Number = 1;
		public var SCALE:Number = 60;
		public var roomId = -1;
		public var menu:Menu = new Menu();
		public var socket:XMLSocket;
		
		public var map;
		
		////////////////////For roomcell dimensions and layout /////////////////////////////
		public var roomcell_startX:Number = 250;
		public var roomcell_startY:Number = 40;
		public var roomcell_width:Number = 180;
		public var roomcell_height:Number = 120;
		public var roomcell_xGap:Number = 40;
		public var roomcell_yGap:Number = 28;
		
		
		////////////////////For information dimensions and layout /////////////////////////////
		public var info_startX:Number = 5;
		public var info_startY:Number = 15;
		public var info_width:Number = 65;
		public var info_height:Number = 15;
		public var info_xGap:Number = 20;
		public var info_yGap:Number = 15;
		
		/////////////////////////////Skillset and buy Bounty///////////////////////////////
		public var skillBounty:Array = new Array(10, 10, 10, 10, 10);
		public var spellsSkilled:Array = new Array();
		public var bounty:Number = 10;
		public var skillBox:MovieClip = new MovieClip();
		public var spellName:Array = new Array("cannon", "homing", "teleport", "invisible", "throttle");
		public var keyName:Array = new Array("Q", "W", "E", "R");
		
		public var spellUsed:Array = new Array(false,false,false,false,false);
		
		
		public function Client() {
			trace(this);
			this.addChild(menu);
			menu.visible = false;
			doConnect(null);
			//stage.addEventListener(MouseEvent.CLICK, doConnect);
		}
		
			function doConnect(evt:MouseEvent):void
			{
				//stage.removeEventListener(MouseEvent.CLICK, doConnect);
				socket = new XMLSocket("127.0.0.1", 9001);
				socket.addEventListener(Event.CONNECT, onConnect);
				socket.addEventListener(IOErrorEvent.IO_ERROR, onError);
				//TweenPlugin.activate([BlurFilterPlugin]);
			}
			
			
			function onConnect(evt:Event):void
			{
				trace("Connected");
				socket.removeEventListener(Event.CONNECT, onConnect);
				//socket.removeEventListener(IOErrorEvent.IO_ERROR, onError);

				socket.addEventListener(DataEvent.DATA, onDataReceived);
				socket.addEventListener(Event.CLOSE, onSocketClose);
			}
			
			function setPlayer():MovieClip {
				var mc:Player = new Player();
				return mc;
			}
			
			function setAmmo(type:int):MovieClip {
				var mc:Ammo = new Ammo(type);
				return mc;
			}			
			
			function showInventory(evt:MouseEvent) {
				//
			}
			
			function calculateDistance(ind:int, isPlayer:Boolean = true):Number {
				var dist:Number;
				if(isPlayer)
					dist = Math.sqrt(Math.pow( (players[ind].remoteX - players[ind].unit.x ), 2) + Math.pow( (players[ind].remoteY - players[ind].unit.y ), 2));
				else
					dist = Math.sqrt(Math.pow( (mouseX - players[ind].unit.x ), 2) + Math.pow( (mouseY - players[ind].unit.y ), 2));
				return dist;
			}
			
			function calculateTime(ind:int):Number {
				var time:Number = Math.sqrt(Math.pow( (players[ind].remoteX - players[ind].unit.x ), 2) + Math.pow( (players[ind].remoteY - players[ind].unit.y ), 2))/players[ind].ms;
				return time;
			}
			
			function onError(evt:IOErrorEvent):void
			{
				trace("Connect failed"+evt);
				socket.removeEventListener(Event.CONNECT, onConnect);
				socket.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				stage.addEventListener(MouseEvent.CLICK, doConnect);
			}
			
			function onClick(evt:MouseEvent) {
				trace(evt.target);
				trace(evt.currentTarget);
				if (weapon == -1)
				{	
					lastClicked.x = mouseX;
					lastClicked.y = mouseY;
					var obj:Object={};
					obj["info"] = "position";
					obj["pid"] = myIndex;
					obj["position"] = { "x":mouseX, "y":mouseY };
					players[myIndex].remoteX = mouseX;
					players[myIndex].remoteY = mouseY;
					MovieClip(players[myIndex].unit.muzzle).rotation = 0;
					//MovieClip(players[myIndex].unit.muzzle).rotation = (dirSin(myIndex)>=0?1:-1)*Math.acos(dirCos(myIndex))*180/Math.PI;
					//TweenMax.to(players[myIndex].unit, extrapolationTime, { x:players[myIndex].unit.x+SPEED*extrapolationTime*dirCos(myIndex), y:players[myIndex].unit.y+SPEED*extrapolationTime*dirSin(myIndex), ease:Linear.easeNone } );				
					sendSocketMessage(obj);
					trace(JSON.encode(obj));
				}else if(weapon==0) {
					var obj:Object={};
					obj["info"] = "ammo";
					obj["type"] = weapon;
					obj["pid"] = myIndex;
					//obj["position"] = { "x":players[myIndex].unit.x+20*dirCos(myIndex, false), "y":players[myIndex].unit.y+20*dirSin(myIndex, false) };
					obj["dir"] = { "cos":dirCos(myIndex, false), "sin":dirSin(myIndex, false) };
					/*
					MovieClip(players[myIndex].unit).rotation = (dirSin(myIndex)>=0?1:-1)*Math.acos(dirCos(myIndex))*180/Math.PI;
					TweenMax.to(players[myIndex].unit, extrapolationTime, { x:players[myIndex].unit.x+SPEED*extrapolationTime*dirCos(myIndex), y:players[myIndex].unit.y+SPEED*extrapolationTime*dirSin(myIndex), ease:Linear.easeNone } );				
					*/
					sendSocketMessage(obj);
					trace(JSON.encode(obj));
					crossHair.visible = false;
					weapon = -1;
				}else if (weapon == 1) {
					var mc = MouseEvent(evt).target;
					trace(mc);
					var found = false;
					var aim:int = -1;
					for (var i = 0; i < players.length; i++)
					{
						if (mc == players[i].unit || mc == players[i].unit.muzzle)
						{	trace(players[i].unit);
						trace(i);
							found = true;
							aim = i;
						}
					}
					if (found)
					{	trace("target found");
						var obj:Object={};
						obj["info"] = "ammo";
						obj["type"] = weapon;
						obj["pid"] = myIndex;
						obj["dir"] = { "cos":dirCos(myIndex, false), "sin":dirSin(myIndex, false) };
						obj["aim"] = aim;
						/*
						MovieClip(players[myIndex].unit).rotation = (dirSin(myIndex)>=0?1:-1)*Math.acos(dirCos(myIndex))*180/Math.PI;
						TweenMax.to(players[myIndex].unit, extrapolationTime, { x:players[myIndex].unit.x+SPEED*extrapolationTime*dirCos(myIndex), y:players[myIndex].unit.y+SPEED*extrapolationTime*dirSin(myIndex), ease:Linear.easeNone } );				
						*/
						trace(JSON.encode(obj));
						sendSocketMessage(obj);
					}else {
						trace("target not found");
					}
					crossHair.visible = false;
					weapon = -1;
					
				}else if(weapon==2) {
					var obj:Object={};
					obj["info"] = "ammo";
					obj["type"] = weapon;
					obj["pid"] = myIndex;
					obj["position"] = { "x":mouseX, "y":mouseY };
					stage.removeEventListener(MouseEvent.CLICK, onClick);
					//obj["dir"] = { "cos":dirCos(myIndex, false), "sin":dirSin(myIndex, false) };
					/*
					MovieClip(players[myIndex].unit).rotation = (dirSin(myIndex)>=0?1:-1)*Math.acos(dirCos(myIndex))*180/Math.PI;
					TweenMax.to(players[myIndex].unit, extrapolationTime, { x:players[myIndex].unit.x+SPEED*extrapolationTime*dirCos(myIndex), y:players[myIndex].unit.y+SPEED*extrapolationTime*dirSin(myIndex), ease:Linear.easeNone } );				
					*/
					trace(JSON.encode(obj));
					sendSocketMessage(obj);
					crossHair.visible = false;
					weapon = -1;
				}else if(weapon==3) {
					
				}
				
			}
			
			function onMove(evt:MouseEvent) {
				crossHair.x = mouseX;
				crossHair.y = mouseY;
				if (weapon != -1)
					MovieClip(players[myIndex].unit.muzzle).rotation = -MovieClip(players[myIndex].unit).rotation+(dirSin(myIndex,false)>=0?1:-1)*Math.acos(dirCos(myIndex,false))*180/Math.PI;
			}
			
			function onKeydown(evt:KeyboardEvent) {
				var code = evt.charCode;
				weapon = -1;
				trace("code:" + code);
				if (code == 27)
				{
					
				}else if (code == 81||code == 113) {
					weapon = 0;
					MovieClip(players[myIndex].unit.muzzle).rotation = -MovieClip(players[myIndex].unit).rotation+(dirSin(myIndex,false)>=0?1:-1)*Math.acos(dirCos(myIndex,false))*180/Math.PI;
				}else if (code==87||code == 119) {
					weapon = 1;
					MovieClip(players[myIndex].unit.muzzle).rotation = -MovieClip(players[myIndex].unit).rotation+(dirSin(myIndex,false)>=0?1:-1)*Math.acos(dirCos(myIndex,false))*180/Math.PI;
				}else if (code==69||code == 101) {
					weapon = 2;
					MovieClip(players[myIndex].unit.muzzle).rotation = -MovieClip(players[myIndex].unit).rotation+(dirSin(myIndex,false)>=0?1:-1)*Math.acos(dirCos(myIndex,false))*180/Math.PI;
				}else if (code==82||code == 114) {
					weapon = 3;
					var obj:Object={};
					obj["info"] = "ammo";
					obj["type"] = weapon;
					obj["pid"] = myIndex;
					//obj["dir"] = { "cos":dirCos(myIndex, false), "sin":dirSin(myIndex, false) };
					/*
					MovieClip(players[myIndex].unit).rotation = (dirSin(myIndex)>=0?1:-1)*Math.acos(dirCos(myIndex))*180/Math.PI;
					TweenMax.to(players[myIndex].unit, extrapolationTime, { x:players[myIndex].unit.x+SPEED*extrapolationTime*dirCos(myIndex), y:players[myIndex].unit.y+SPEED*extrapolationTime*dirSin(myIndex), ease:Linear.easeNone } );				
					*/
					trace(JSON.encode(obj));
					sendSocketMessage(obj);
					weapon = -1;
					
				}else if (code==65||code == 97) {
					weapon = 5;
					var obj:Object={};
					obj["info"] = "ammo";
					obj["type"] = weapon;
					obj["pid"] = myIndex;
					//obj["dir"] = { "cos":dirCos(myIndex, false), "sin":dirSin(myIndex, false) };
					/*
					MovieClip(players[myIndex].unit).rotation = (dirSin(myIndex)>=0?1:-1)*Math.acos(dirCos(myIndex))*180/Math.PI;
					TweenMax.to(players[myIndex].unit, extrapolationTime, { x:players[myIndex].unit.x+SPEED*extrapolationTime*dirCos(myIndex), y:players[myIndex].unit.y+SPEED*extrapolationTime*dirSin(myIndex), ease:Linear.easeNone } );				
					*/
					trace(JSON.encode(obj));
					sendSocketMessage(obj);
					weapon = -1;
				}else {
					weapon = -1;
				}
				
				if ([0,1,2].indexOf(weapon) > -1)
				{
					crossHair.visible = true;
				}else {
					crossHair.visible = false;
				}
			}
			
			function onDataReceived(evt:DataEvent):void
			{	
				trace(DataEvent(evt).data);
				if (DataEvent(evt).data.indexOf("<?xml") < 0)
				{	var crudeData = JSON.decode(DataEvent(evt).data);
					var infoVar:String = String(JSON.decode(DataEvent(evt).data).info);
					if (infoVar == "player")
					{	
						trace("got player id message");
						players[crudeData.pid] = setPlayer();
						stage.addChild(players[crudeData.pid].unit);
						MovieClip(players[crudeData.pid].unit).addEventListener(MouseEvent.CLICK, showInventory, false, 0, true);
						stage.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
						stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove, false, 0, true);
						stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeydown, false, 0, true);
						skillBox.x = 230;
						skillBox.y = 640;
						this.addChild(skillBox);
						players[crudeData.pid].unit.x = crudeData.position["x"]*SCALE;
						players[crudeData.pid].unit.y = crudeData.position["y"] * SCALE;
						players[crudeData.pid].unit.rotation = crudeData.angle;
						players[crudeData.pid].remoteX = crudeData.position["x"]*SCALE;
						players[crudeData.pid].remoteY = crudeData.position["y"]*SCALE;
						players[crudeData.pid].ms = crudeData.ms;
						players[crudeData.pid].hp = crudeData.hp;
						players[crudeData.pid].regen = crudeData.regen;
						myIndex = crudeData.pid;
						
						//add crosshair to the stage
						stage.addChild(crossHair);
						crossHair.visible = false;
						
						
					}else if (infoVar == "position") 
					{
						trace("got player position message");
						for (var z = 0; z < crudeData.data.length; z++)
						{	var curr = crudeData.data[z];
							if (curr.pid != myIndex) {
								
							}else {
								
							}
							
							players[curr.pid].unit.x = curr.position["x"]*SCALE;
							players[curr.pid].unit.y = curr.position["y"] * SCALE;
							players[curr.pid].unit.rotation = curr.angle;
							/*
							players[curr.pid].remoteX = curr.finalpos["x"];
							players[curr.pid].remoteY = curr.finalpos["y"];
							*/
							//TweenMax.killTweensOf(players[curr.pid].unit);
							//TweenMax.to(players[curr.pid].unit, fadetime,{alpha:1});
							//MovieClip(players[curr.pid].unit).rotation = 180 * Math.atan2( curr.yStep,curr.xStep) / 3.141593;
							//MovieClip(players[curr.pid].unit).rotation = (dirSin(curr.pid)>=0?1:-1)*Math.acos(dirCos(curr.pid))*180/Math.PI;
							//TweenMax.to(players[curr.pid].unit, calculateTime(curr.pid), { x:curr.finalpos["x"], y:curr.finalpos["y"], ease:Linear.easeNone } );
							//TweenMax.to(players[curr.pid].unit, 0.1, { x:curr.position["x"]+curr.xStep, y:curr.position["y"]+curr.yStep, ease:Linear.easeNone } );
						}
						
					}else if (infoVar == "map")
					{	map = new Map();
						this.addChild(map);
						trace("got map message");
						for (var i = 0; i < crudeData.data.walls.length; i++)
						{	
							var wall:Wall = new Wall();
							wall.x = crudeData.data.walls[i][0];
							wall.y = crudeData.data.walls[i][1];
							wall.rotation = crudeData.data.walls[i][2];
							this.addChild(wall);
						}
						
						for (var i = 0; i < crudeData.data.pillars.length; i++)
						{	
							var pillar:Pillar = new Pillar();
							pillar.x = crudeData.data.pillars[i][0];
							pillar.y = crudeData.data.pillars[i][1];
							this.addChild(pillar);
							
						}
							
					}else if (infoVar == "hp") 
					{
						trace("got player hp message");
						for (var z = 0; z < crudeData.data.length; z++)
						{	var curr = crudeData.data[z];
							if (curr.pid == myIndex) {
								players[myIndex].remoteX = curr.position["x"];
								players[myIndex].remoteY = curr.position["y"];
								trace("clientx set::" + players[myIndex].unit.x);
								trace("clienty set::" + players[myIndex].unit.y);
								
								//players[myIndex].unit.x = curr.position["x"];
								//players[myIndex].unit.y = curr.position["y"];
								
								trace("remotex set::" + players[myIndex].remoteX);
								trace("remotey set::"+players[myIndex].remoteY);
								TweenMax.killTweensOf(players[myIndex].unit);
								MovieClip(players[myIndex].unit).rotation = (dirSin(myIndex)>=0?1:-1)*Math.acos(dirCos(myIndex))*180/Math.PI;
								//TweenMax.to(players[myIndex].unit, extrapolationTime, { x:players[myIndex].unit.x+SPEED*extrapolationTime*cos, y:players[myIndex].unit.y+SPEED*extrapolationTime*sin, ease:Linear.easeNone } );
								TweenMax.to(players[myIndex].unit, 0.1, { x:curr.position["x"], y:curr.position["y"], ease:Linear.easeNone } );
							}else {
								players[curr.pid].unit.x = players[curr.pid].remoteX;
								players[curr.pid].unit.y = players[curr.pid].remoteY;
								players[curr.pid].remoteX=curr.position["x"];
								players[curr.pid].remoteY = curr.position["y"];
								
								MovieClip(players[curr.pid].unit).rotation = (dirSin(curr.pid)>=0?1:-1)*Math.acos(dirCos(curr.pid))*180/Math.PI;
								TweenMax.to(players[curr.pid].unit, 0.1, { x:curr.position["x"], y:curr.position["y"], ease:Linear.easeNone } );
							}
						}
						
					}else if (infoVar == "newjoin")
					{
						trace("got player join message");
						players[crudeData.pid] = setPlayer();
						stage.addChild(players[crudeData.pid].unit);
						players[crudeData.pid].unit.x = crudeData.position["x"]*SCALE;
						players[crudeData.pid].unit.y = crudeData.position["y"] * SCALE;
						players[crudeData.pid].unit.rotation = crudeData.angle;
						players[crudeData.pid].remoteX = crudeData.position["x"]*SCALE;
						players[crudeData.pid].remoteY = crudeData.position["y"]*SCALE;
						players[crudeData.pid].ms = crudeData.ms;
						players[crudeData.pid].hp = crudeData.hp;
						players[crudeData.pid].regen = crudeData.regen;
						
					}else if (infoVar == "left")
					{
						trace("got player disconnect message");
						if (stage.getChildIndex(players[crudeData.pid].unit) >-1)
							stage.removeChild(players[crudeData.pid].unit);
							
					}else if (infoVar == "ammo")
					{
						//trace("got ammo message");
						for (var z = 0; z < crudeData.data.length; z++)
						{	var curr = crudeData.data[z];
							//trace(curr.type);
							
							if (ammo[curr.pid] != null)
							{	//trace("this ammo found");
								if (stage.contains(ammo[curr.pid].unit) ==false)
								{	//trace("this ammo wasnt added");
									ammo[curr.pid] = setAmmo(curr.type);
									stage.addChild(ammo[curr.pid].unit);
									if(curr.type==0)
										ammo[curr.pid].unit.addEventListener(Event.ENTER_FRAME, rotateCannon);
									else
										ammo[curr.pid].unit.addEventListener(Event.ENTER_FRAME, doTrail);
								}
							}else {
								//trace("this ammo wasnt found");
								ammo[curr.pid] = setAmmo(curr.type);
								stage.addChild(ammo[curr.pid].unit);
								if(curr.type==0)
									ammo[curr.pid].unit.addEventListener(Event.ENTER_FRAME, rotateCannon);
								else
									ammo[curr.pid].unit.addEventListener(Event.ENTER_FRAME, doTrail);
							}
							ammo[curr.pid].unit.x = curr.position["x"]*SCALE;
							ammo[curr.pid].unit.y = curr.position["y"] * SCALE;
							if(curr.type==1)
								ammo[curr.pid].unit.rotation = curr.angle;
							ammo[curr.pid].remoteX = curr.position["x"]*SCALE;
							ammo[curr.pid].remoteY = curr.position["y"]*SCALE;
							TweenMax.killTweensOf(ammo[curr.pid].unit);
							
						}
					}else if (infoVar == "missilesLost")
					{
						trace("got missileLost message");
						
								removeAmmo(crudeData.pid);
							
						
					}else if (infoVar == "tanksHurt")
					{
						trace("got tanksHurt message");
						MovieClip(players[crudeData.pid].unit.hp.hp_alive).scaleX = crudeData.hp / 400;						
							
					}else if (infoVar == "teleportStarted") 
					{
						trace("got player teleportstart message");
											
							//players[crudeData.pid].unit.x = crudeData.position["x"];
							//players[crudeData.pid].unit.y = crudeData.position["y"];
							/*
							players[curr.pid].remoteX = curr.finalpos["x"];
							players[curr.pid].remoteY = curr.finalpos["y"];
							*/
							TweenMax.killTweensOf(players[crudeData.pid].unit);
							//MovieClip(players[curr.pid].unit).rotation = 180 * Math.atan2( curr.yStep,curr.xStep) / 3.141593;
							//MovieClip(players[curr.pid].unit).rotation = (dirSin(curr.pid)>=0?1:-1)*Math.acos(dirCos(curr.pid))*180/Math.PI;
							//TweenMax.to(players[curr.pid].unit, calculateTime(curr.pid), { x:curr.finalpos["x"], y:curr.finalpos["y"], ease:Linear.easeNone } );
							
							TweenMax.to(players[crudeData.pid].unit, 0.5, {blurFilter:{blurX:40,blurY:0, quality:3}});
							//TweenMax.to(players[curr.pid].unit, 0.1, { x:curr.position["x"]+curr.xStep, y:curr.position["y"]+curr.yStep, ease:Linear.easeNone } );
						
						
					}else if (infoVar == "teleportEnded") 
					{
						trace("got player teleportend message");
							stage.addEventListener(MouseEvent.CLICK, onClick,false,0,true);
				
							//players[crudeData.pid].unit.x = crudeData.position["x"];
							//players[crudeData.pid].unit.y = crudeData.position["y"];
							/*
							players[curr.pid].remoteX = curr.finalpos["x"];
							players[curr.pid].remoteY = curr.finalpos["y"];
							*/
							TweenMax.killTweensOf(players[crudeData.pid].unit);
							//MovieClip(players[curr.pid].unit).rotation = 180 * Math.atan2( curr.yStep,curr.xStep) / 3.141593;
							//MovieClip(players[curr.pid].unit).rotation = (dirSin(curr.pid)>=0?1:-1)*Math.acos(dirCos(curr.pid))*180/Math.PI;
							//TweenMax.to(players[curr.pid].unit, calculateTime(curr.pid), { x:curr.finalpos["x"], y:curr.finalpos["y"], ease:Linear.easeNone } );
							
							players[crudeData.pid].unit.x = crudeData.position.x*SCALE;
							players[crudeData.pid].unit.y = crudeData.position.y*SCALE;
							TweenMax.to(players[crudeData.pid].unit, 0.5, {blurFilter:{blurX:0,blurY:0, quality:3}});
							//TweenMax.to(players[curr.pid].unit, 0.1, { x:curr.position["x"]+curr.xStep, y:curr.position["y"]+curr.yStep, ease:Linear.easeNone } );
						
						
					}
					else if (infoVar == "invisible") 
					{
						trace("got player teleport message");
											
							//players[crudeData.pid].unit.x = crudeData.position["x"];
							//players[crudeData.pid].unit.y = crudeData.position["y"];
							/*
							players[curr.pid].remoteX = curr.finalpos["x"];
							players[curr.pid].remoteY = curr.finalpos["y"];
							*/
							//TweenMax.killTweensOf(players[crudeData.pid].unit);
							//MovieClip(players[curr.pid].unit).rotation = 180 * Math.atan2( curr.yStep,curr.xStep) / 3.141593;
							//MovieClip(players[curr.pid].unit).rotation = (dirSin(curr.pid)>=0?1:-1)*Math.acos(dirCos(curr.pid))*180/Math.PI;
							//TweenMax.to(players[curr.pid].unit, calculateTime(curr.pid), { x:curr.finalpos["x"], y:curr.finalpos["y"], ease:Linear.easeNone } );
							
							TweenMax.to(players[crudeData.pid].unit, fadetime,{alpha:0});
							//TweenMax.to(players[curr.pid].unit, 0.1, { x:curr.position["x"]+curr.xStep, y:curr.position["y"]+curr.yStep, ease:Linear.easeNone } );
							//setTimeout(function() { unFade(crudeData.pid); }, crudeData.time * 100);
						
						
					}else if (infoVar == "visible") 
					{
						trace("got player teleport message");
											
							//players[crudeData.pid].unit.x = crudeData.position["x"];
							//players[crudeData.pid].unit.y = crudeData.position["y"];
							/*
							players[curr.pid].remoteX = curr.finalpos["x"];
							players[curr.pid].remoteY = curr.finalpos["y"];
							*/
							
							//TweenMax.killTweensOf(players[crudeData.pid].unit);
							//MovieClip(players[curr.pid].unit).rotation = 180 * Math.atan2( curr.yStep,curr.xStep) / 3.141593;
							//MovieClip(players[curr.pid].unit).rotation = (dirSin(curr.pid)>=0?1:-1)*Math.acos(dirCos(curr.pid))*180/Math.PI;
							//TweenMax.to(players[curr.pid].unit, calculateTime(curr.pid), { x:curr.finalpos["x"], y:curr.finalpos["y"], ease:Linear.easeNone } );
							TweenMax.to(players[crudeData.pid].unit, fadetime,{alpha:1});
							//TweenMax.to(players[crudeData.pid].unit, fadetime,{alpha:0});
							//TweenMax.to(players[curr.pid].unit, 0.1, { x:curr.position["x"]+curr.xStep, y:curr.position["y"]+curr.yStep, ease:Linear.easeNone } );
							//setTimeout(function() { unFade(crudeData.pid); }, crudeData.time * 100);
						
						
					}else if (infoVar == "joinOk")
					{	
						trace("got roomjoin message..");
						menu.visible = false;
						roomId = crudeData.roomId;
						var obj:Object={};
						obj["info"] = "join";
						sendSocketMessage(obj);
						
					}else if (infoVar == "spellSelect")
					{	
						trace("got spellSelect message..");
						var skillmenu:SelectionBox = new SelectionBox();
						skillmenu.name = "skillmenu";
						skillmenu.x = 230;
						skillmenu.y = 580;
						this.addChild(skillmenu);						
						
						for (var i = 0; i < skillBounty.length; i++)
						{
							if (spellsSkilled.indexOf(i)>-1)
							{
								trace("spell already skilled up");
								MovieClip(MovieClip(skillmenu).getChildByName(spellName[i])).info.text = "Used Up!";
								
								
							}else if (skillBounty[i]>bounty) {
								
								trace("not enough bounty");
								MovieClip(MovieClip(skillmenu).getChildByName(spellName[i])).info.text = "Cannot Buy!";
								
							}else {
								trace("Available");
								MovieClip(skillmenu).getChildByName(spellName[i]).addEventListener(MouseEvent.CLICK, selectSpell, false, 0, true);
								MovieClip(MovieClip(skillmenu).getChildByName(spellName[i])).info.text = "Available!";
							}
						}
						
						
					}else if (infoVar == "rmList")
					{	trace("got roomList message..");
						trace(crudeData);
						if (this.getChildByName("lobby") != null)
						{
							this.removeChild(this.getChildByName("lobby"));
						}
						var lobby:MovieClip = new MovieClip();
						lobby.name = "lobby";
						for (var i = 0; i < crudeData.rooms.length; i++)
						{
							var square:Sprite = new Sprite();
							square.graphics.beginFill(0xCCCCCC);
							square.graphics.drawRect(0,0,180,120);
							square.graphics.endFill();
							square.x = roomcell_startX+(i%2)*(roomcell_width+roomcell_xGap);
							square.y = roomcell_startY + int(i / 2) * (roomcell_height + roomcell_yGap);
							var title:TextField = new TextField();
							title.text = "Arena-" + crudeData.rooms[i].roomId;
							title.x = 60;
							title.y = 5;
							square.addChild(title);
							for (var j = 0; j < crudeData.rooms[i].players.length; j++)
							{
								var info:TextField = new TextField();
								info.text = crudeData.rooms[i].players[j].username;
								info.x = info_startX+(j%2)*(info_width+info_xGap);
								info.y = info_startY + int(j / 2) * (info_height + info_yGap);
								square.addChild(info);
							}
							lobby.addChild(square);
							
							if (crudeData.rooms[i].players.length<6) {
								var joinbut:JoinArena = new JoinArena();
								joinbut.x = 20;
								joinbut.y = 80;
								joinbut.name = crudeData.rooms[i].roomId;
								square.addChild(joinbut);
								joinbut.addEventListener(MouseEvent.CLICK,joinArena,false,0,true);
							}
							
						}
						this.addChild(lobby);
					}
				}else {
					menu.visible = true;
					menu.find.addEventListener(MouseEvent.CLICK, findGames, false, 0, true);
					menu.create.addEventListener(MouseEvent.CLICK, createGame, false, 0, true);
					
					
				}
			}
			
			function selectSpell(evt:MouseEvent) {
				var selected = evt.currentTarget.name;
				trace(selected);
				if (selected != null)
				{
					var obj = { };
					obj["info"] = "spellSelected";
					obj["pid"] = myIndex;
					obj["selected"] = -1;
					if (selected == "cannon") {
						obj["selected"] = 0;
					}else if (selected == "homing") {
						obj["selected"] = 1;
					}else if (selected == "teleport") {
						obj["selected"] = 2;
					}else if (selected == "invisible") {
						obj["selected"]= 3;
					}else if (selected == "throttle") {
						obj["selected"]= 4;
					}
					sendSocketMessage(obj);
					
					if (this.getChildByName("skillmenu") !=null) {
						this.removeChild(this.getChildByName("skillmenu"));
						var mc:Spell = new Spell();
						mc.name = obj["selected"];
						mc.key.text = keyName[spellsSkilled.length];
						mc.spell.text = spellName[obj["selected"]];
						mc.x = spellsSkilled.length * mc.width;
						mc.addEventListener(MouseEvent.CLICK, cast, false, 0, true);
						skillBox.addChild(mc);
						spellsSkilled.push(selected);
					}
					
				}
			}
			
			function cast(evt:MouseEvent) {
				var name = evt.currentTarget.name;
				trace("spell cast is:" + name);
				weapon = -1;
				if (name == null)
				{
					
				}else if (name == 0) {
					weapon = 0;
					MovieClip(players[myIndex].unit.muzzle).rotation = -MovieClip(players[myIndex].unit).rotation+(dirSin(myIndex,false)>=0?1:-1)*Math.acos(dirCos(myIndex,false))*180/Math.PI;
				}else if (name==1) {
					weapon = 1;
					MovieClip(players[myIndex].unit.muzzle).rotation = -MovieClip(players[myIndex].unit).rotation+(dirSin(myIndex,false)>=0?1:-1)*Math.acos(dirCos(myIndex,false))*180/Math.PI;
				}else if (name==2) {
					weapon = 2;
					MovieClip(players[myIndex].unit.muzzle).rotation = -MovieClip(players[myIndex].unit).rotation+(dirSin(myIndex,false)>=0?1:-1)*Math.acos(dirCos(myIndex,false))*180/Math.PI;
				}else if (name==3) {
					weapon = 3;
					var obj:Object={};
					obj["info"] = "ammo";
					obj["type"] = weapon;
					obj["pid"] = myIndex;
					//obj["dir"] = { "cos":dirCos(myIndex, false), "sin":dirSin(myIndex, false) };
					/*
					MovieClip(players[myIndex].unit).rotation = (dirSin(myIndex)>=0?1:-1)*Math.acos(dirCos(myIndex))*180/Math.PI;
					TweenMax.to(players[myIndex].unit, extrapolationTime, { x:players[myIndex].unit.x+SPEED*extrapolationTime*dirCos(myIndex), y:players[myIndex].unit.y+SPEED*extrapolationTime*dirSin(myIndex), ease:Linear.easeNone } );				
					*/
					trace(JSON.encode(obj));
					sendSocketMessage(obj);
					weapon = -1;
					
				}else if (name==4) {
					weapon = 4;
					var obj:Object={};
					obj["info"] = "ammo";
					obj["type"] = weapon;
					obj["pid"] = myIndex;
					//obj["dir"] = { "cos":dirCos(myIndex, false), "sin":dirSin(myIndex, false) };
					/*
					MovieClip(players[myIndex].unit).rotation = (dirSin(myIndex)>=0?1:-1)*Math.acos(dirCos(myIndex))*180/Math.PI;
					TweenMax.to(players[myIndex].unit, extrapolationTime, { x:players[myIndex].unit.x+SPEED*extrapolationTime*dirCos(myIndex), y:players[myIndex].unit.y+SPEED*extrapolationTime*dirSin(myIndex), ease:Linear.easeNone } );				
					*/
					trace(JSON.encode(obj));
					sendSocketMessage(obj);
					weapon = -1;
				}else {
					weapon = -1;
				}
				
				if ([0,1,2,3,4].indexOf(name)>-1) {
					spellUsed[name] = true;
				}
				
				if ([0,1,2].indexOf(weapon) > -1)
				{
					crossHair.visible = true;
				}else {
					crossHair.visible = false;
				}
				
			}
			
			function joinArena(evt:MouseEvent) {
				if (this.getChildByName("lobby") != null)
				{
					this.removeChild(this.getChildByName("lobby"));
				}
				trace(evt.target.name);
				roomId = evt.target.name;
				menu.visible = false;
				var obj:Object={};
				obj["info"] = "join";
				sendSocketMessage(obj);
			}
			
			function createGame(evt:MouseEvent) {
				var pop:PrivateTable = new PrivateTable();
				pop.createBtn.addEventListener(MouseEvent.CLICK, createArena, false, 0, true);
				pop.closeBtn.addEventListener(MouseEvent.CLICK, closePopup, false, 0, true);
				trace(this);
				pop.x = 250;
				pop.y = 150;
				this.addChild(pop);
				
			}
			
			function createArena(evt:MouseEvent) {
				var arenaName:String = evt.target.parent.ArenaName.text;
				var password:String = evt.target.parent.password.text;
				
				trace("sending createRoom message..");
					var obj:Object={};
					obj["info"] = "createRoom";
					obj["arenaName"] = arenaName;
					obj["password"] = password;
					sendSocketMessage(obj);
				this.removeChild(evt.target.parent);	
			}
			
			function closePopup(evt:MouseEvent) {
				this.removeChild(evt.target.parent);
			}
			
			function findGames(evt:MouseEvent) {
					trace("sending createRoom message..");
					var obj:Object={};
					obj["info"] = "roomList";
					sendSocketMessage(obj);
			}
			
			function sendSocketMessage(obj:Object) {
				obj["roomId"] = roomId;
				socket.send(JSON.encode(obj));
			}
			
			function rotateCannon(evt:Event) {
				var mc = evt.target;
				//trace(mc);
				//trace(mc.rotation);
				if (mc != null) {
					mc.rotation += 20;
				}
			}
			
			function doTrail(evt:Event)
			{	
				var targetX = evt.target.x;
				var targetY = evt.target.y;
				var _loc3:Smoke = new Smoke();
				stage.addChild(_loc3);
				_loc3.x = targetX;
				_loc3.y = targetY;
				_loc3.rotation = 360*Math.random();
				var randomScale = 0.75*Math.random() + 0.25;
				MovieClip(_loc3).scaleX = randomScale;
				var randomScale = 0.75*Math.random() + 0.25;
				_loc3.scaleX = randomScale;
				_loc3.speed = 0.10*Math.random() + 0.05;
				//updateAfterEvent();
				_loc3.addEventListener(Event.ENTER_FRAME, spreadSmoke);
				
				
			} // End of the function
			
			function spreadSmoke(evt:Event)
			{		var _loc3 = evt.target;
					_loc3.scaleX = _loc3.scaleX + _loc3.speed;
					_loc3.scaleX = _loc3.scaleX + _loc3.speed;
					_loc3.alpha = _loc3.alpha - _loc3.speed;
					//trace(_loc3.alpha);
					if (_loc3.alpha <= 0)
					{
						//delete this.onEnterFrame;
						stage.removeChild(_loc3);
						_loc3.removeEventListener(Event.ENTER_FRAME, spreadSmoke);
					} // end if
			}
			
			function addExplosion(pid, explosionParticleAmount=15, explosionDistance=25, explosionSize=100, explosionAlpha=0.75)
			{	//trace(targetX + "<<<<" + targetY);
				var dummy:MovieClip = new MovieClip();
				dummy.name = pid;
				stage.addChild(dummy);
				dummy.x = ammo[pid].unit.x;
				dummy.y = ammo[pid].unit.y;
				for (var _loc6 = 0; _loc6 < explosionParticleAmount; ++_loc6)
				{
					var _loc1:Explosion2 = new Explosion2();
					dummy.addChild(_loc1);
					var _loc3:Explosion = new Explosion();
					dummy.addChild(_loc3);
					_loc3.x = Math.random()*explosionDistance - explosionDistance / 2;
					_loc3.y =   Math.random()*explosionDistance - explosionDistance / 2;
					_loc1.x =  Math.random()*explosionDistance - explosionDistance / 2;
					_loc1.y =  Math.random() * explosionDistance - explosionDistance / 2;
					/*trace("clip1 x::" + _loc1.x);
					trace("clip2 x::" + _loc3.x);
					trace("clip1 y::" + _loc1.y);
					trace("clip2 y::" + _loc3.y);*/
					var _loc5 = (explosionSize*Math.random() + explosionSize / 2)/100;
					_loc3.scaleX = _loc5;
					_loc3.scaleY = _loc5;/*
					trace("clip2 scalex x::" + _loc3.scaleX);
					trace("clip2 scalex y::" + _loc3.scaleY);*/
					_loc5 = (explosionSize*Math.random() + explosionSize / 2)/100;
					_loc1.scaleX = _loc5;
					_loc1.scaleY = _loc5;/*
					trace("clip1 scalex x::" + _loc1.scaleX);
					trace("clip1 scalex y::" + _loc1.scaleY);*/
					_loc1.rotation = 359 * Math.random();
					//trace("clip1 scalex x::" + _loc1.rotation);
					_loc3.alpha = explosionAlpha*Math.random() + explosionAlpha / 4;
					_loc1.alpha = explosionAlpha * Math.random() + explosionAlpha / 4;
					/*
					trace("clip1 alpha ::" + _loc1.alpha);
					trace("clip2 alpha ::" + _loc3.alpha);*/
				} // end of for
				//trace(stage.getChildByName(pid));
				setTimeout(function() { stage.removeChild(stage.getChildByName(pid)); }, 666);
			} // End of the function
			
			function removeAmmo(id:Number) {
				
				addExplosion(id);
				ammo[id].unit.removeEventListener(Event.ENTER_FRAME, rotateCannon);
				ammo[id].unit.removeEventListener(Event.ENTER_FRAME, doTrail);
				TweenMax.killTweensOf(ammo[id].unit);
				if(stage.contains(ammo[id].unit))
					stage.removeChild(ammo[id].unit);
			}
			
			function dirCos(index:int,isPlayer:Boolean=true):Number {
				var diff;
				var retval;
				if (isPlayer)
					diff =  players[index].remoteX-players[index].unit.x ;	
				else
					diff =  mouseX - players[index].unit.x ;
					
				retval = calculateDistance(index,isPlayer);
				return (diff/retval);
			}
			
			function dirSin(index:int,isPlayer:Boolean=true):Number {
				var diff;
				var retval;
				if (isPlayer)
					diff =players[index].remoteY- players[index].unit.y ;
				else
					diff =mouseY- players[index].unit.y ;
				
				retval = calculateDistance(index,isPlayer);
				return (diff/retval);
			}
			
			function onSocketClose(evt:Event):void
			{
				trace("Connection Closed");
				//stage.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
				socket.removeEventListener(Event.CLOSE, onSocketClose);
				socket.removeEventListener(DataEvent.DATA, onDataReceived);
			}


		}
	}
	
