// ** AUTO-UI IMPORT STATEMENTS **
import mx.controls.TextInput;
import mx.controls.Button;
import mx.controls.List;
// ** END AUTO-UI IMPORT STATEMENTS **
import org.red5.utils.GlobalObject;
import org.red5.net.Connection;
import com.gskinner.events.GDispatcher;
import org.red5.utils.Delegate;
import com.blitzagency.util.SimpleDialog;

class org.red5.samples.games.othello.MultiPlayerManager extends MovieClip {
// Constants:
	public static var CLASS_REF = org.red5.samples.games.othello.MultiPlayerManager;
	public static var LINKAGE_ID:String = "org.red5.samples.games.othello.MultiPlayerManager";
// Public Properties:
	public var addEventDispatcher:Function
	public var removeEventDispatcher:Function;
	public var soConnected:Boolean;
	public var localUserName:String;
// Private Properties:
	private var dispatchEvent:Function;
	private var so:GlobalObject;
	private var alert:SimpleDialog;
	private var connection:Connection;
	private var res:Object;
// UI Elements:

// ** AUTO-UI ELEMENTS **
	private var black:TextInput;
	private var joinGame:Button;
	private var newUserName:TextInput;
	private var players:List;
	private var startGame:Button;
	private var white:TextInput;
// ** END AUTO-UI ELEMENTS **

// Initialization:
	private function MultiPlayerManager() {GDispatcher.initialize(this);}
	private function onLoad():Void {}

// Public Methods:
	
	
	public function registerAlert(p_alert:SimpleDialog):Void
	{
		alert = p_alert;
	}
	
	public function configUI(p_connection:Connection, p_userName:String):Void 
	{
		_global.tt("configUI", p_connection.connected, p_userName);
		localUserName = p_userName;
		// setup buttons
		joinGame.addEventListener("click", Delegate.create(this, createGameSO));
		startGame.addEventListener("click", Delegate.create(this, createGame));
		
		res = new Object();
		res.container = this;
		res.onResult = function(obj:Object)
		{
			//_global.tt("Userlist returned", obj);
			this.container.populateList(obj);
		}
		
		registerConnection(p_connection);
		
		
		
		so = new GlobalObject();
		soConnected = so.connect("othelloRoomList", p_connection, false);
		so.addEventListener("onSync", this);
		
		getUserList();
	}
// Semi-Private Methods:
// Private Methods:

	private function createGameSO():Void
	{
		// check to make sure they've clicked on a user
		if(players.selectedItem == undefined || players.selectedItem.data == localUserName)
		{
			alert.show("Please select a player who's waiting...");
			return;
		}
	}

	private function registerConnection(p_connection:Connection):Void
	{
		connection = p_connection;
	}
	
	private function getUserList():Void
	{
		connection.call("getUserList", res);
	}
	
	private function populateList(obj:Object):Void
	{
		_global.tt("got userlist", obj);
		players.removeAll();
		for(var items:String in obj)
		{
			players.addItem({label:obj[items].userName, data:obj[items].userName})
		}
		
		updateSOList();
	}
	
	private function getRoom():Void
	{
		// get the room list and set to the list view
		var ary:Array = so.getData("mainLobby");
		
		//_global.tt("getRoom", ary);
		players.removeAll();
		for(var i:Number=0;i<ary.length;i++)
		{
			players.addItem({label:ary[i].label, data:ary[i].data})
		}
	}
	
	private function onSync(evtObj:Object):Void
	{
		_global.tt("onSync", evtObj);
		getRoom();
	}
	
	private function createGame():Void
	{
		disableStartGame();
		black.text = localUserName;
		updateStatus();
	}
	
	private function checkDuplicatePlayers(p_name:String):Boolean
	{
		for(var i:Number = 0;i<players.length;i++)
		{
			if(players.getItemAt(i).data == p_name) return true;
		}
		return false;
	}
	
	/*
	private function removeUser():Void
	{
		for(var i:Number = 0;i<players.length;i++)
		{
			if(players.getItemAt(i).data == localUserName)
			{
				players.removeItemAt(i);
			}
		}
		
		updateSOList();
	}
	*/
	
	private function updateStatus():Void
	{
		for(var i:Number = 0;i<players.length;i++)
		{
			if(players.getItemAt(i).data == localUserName)
			{
				var label:String = players.getItemAt(i).label;
				players.getItemAt(i).label = label + " is waiting...";
			}
		}
		
		updateSOList();
	}
	
	private function updateSOList():Void
	{
		var ary:Array = new Array();
		var obj:Object = players.dataProvider;
		for(var items:String in obj)
		{
			ary.push({label: obj[items].label, data: obj[items].data});
		}
		ary.sortOn("label");
		so.setData("mainLobby", ary);
	}
	
	private function enableStartGame():Void
	{
		startGame.enabled = true;
	}
	
	private function disableStartGame():Void
	{
		startGame.enabled = false;
	}
	
	private function enableJoin():Void
	{
		joinGame.enabled = true;
		newUserName.enabled = true;
	}
	
	private function disableJoin():Void
	{
		joinGame.enabled = false;
		newUserName.enabled = false;
	}
	
	/*
	private function addUser():Void
	{
		// check addNewUser is not empty
		// check for duplicates
		// addName
		// update SO
		
		if(newUserName.text.length < 1 || checkDuplicatePlayers(newUserName.text))
		{
			alert.title = "Invalide Entry";
			alert.show("Please enter a unique player name.")
			return;
		}
		
		connection.call("addUserName", res, newUserName.text);
		players.addItem({label:newUserName.text, data:newUserName.text});
		
		// set localUserName
		localUserName = newUserName.text;
		
		// now that they are already joined up, disable the controls
		disableJoin();
		
		// updating the mainLobby will force everyone else to get a copy
		updateSOList();
	}
	*/
}