package  {
	
	import flash.display.MovieClip;
	import mx.utils.Base64Encoder;
	import com.worlize.websocket.*;
	import flash.utils.ByteArray;
	
	public class ClientWebsocket extends MovieClip {
		
		
		public function ClientWebsocket() {
			var websocket:WebSocket = new WebSocket("wss://localhost:8080", "*","my-chat-protocol");
			//websocket.enableDeflateStream = true;
			websocket.addEventListener(WebSocketEvent.CLOSED, handleWebSocketClosed);
			websocket.addEventListener(WebSocketEvent.OPEN, handleWebSocketOpen);
			websocket.addEventListener(WebSocketEvent.MESSAGE, handleWebSocketMessage);
			websocket.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, handleConnectionFail);
			websocket.connect();

			function handleWebSocketOpen(event:WebSocketEvent):void {
			  trace("Connected");
			  websocket.sendUTF("Hello World!\n");

			  var binaryData:ByteArray = new ByteArray();
			  binaryData.writeUTF("Hello as Binary Message!");
			  websocket.sendBytes(binaryData);
			}

			function handleWebSocketClosed(event:WebSocketEvent):void {
			  trace("Disconnected");
			}

			function handleConnectionFail(event:WebSocketErrorEvent):void {
			  trace("Connection Failure: " + event.text);
			}

			function handleWebSocketMessage(event:WebSocketEvent):void {
			  if (event.message.type === WebSocketMessage.TYPE_UTF8) {
				trace("Got message: " + event.message.utf8Data);
			  }
			  else if (event.message.type === WebSocketMessage.TYPE_BINARY) {
				trace("Got binary message of length " + event.message.binaryData.length);
			  }
			}
		}
	}
	
}
