extends Node;

func is_facing_wall() -> bool:
	return false;

var functions: Dictionary[ String, Callable ] = {
	"move_up": func () -> void:
		Globals.player.target_position.z -= 1,
	"move_down": func () -> void:
		Globals.player.target_position.z += 1,
	"move_left": func () -> void:
		Globals.player.target_position.x -= 1,
	"move_right": func () -> void:
		Globals.player.target_position.x += 1,
	"log": func (message) -> void:
		_logger.call(message)
		print("Message from Node.JS environment: ", message),
	"is_facing_wall": func() -> bool:
		return Globals.player.is_facing_wall;
};

var server: TCPServer;
var client: StreamPeerTCP;
var _nodePid: int = 0;
var _logger: Callable;

func _open_session() -> void:
	if server != null:
		server.stop();
	client = null;
	server = TCPServer.new();
	server.listen(5000);

func _process(_delta: float) -> void:
	if server != null and server.is_connection_available() and client == null:
		client = server.take_connection();
	
	if client == null or client.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		return;
	
	var message: String = client.get_utf8_string(client.get_available_bytes());
	if message.length() == 0:
		return;
	
	for token in message.split("|", false):
		var action = token.split(":")[ 0 ];
		var value = token.split(":")[ 1 ];
		match action:
			"call":
				var function = value.split("?")[ 0 ] if "?" in value else value;
				var parameter = value.split("?")[ 1 ] if "?" in value else null;
				if function in functions:
					var returnValue = functions[ function ].call(parameter) if parameter != null else functions[ function ].call();
					if returnValue != null:
						client.put_data(("return:" + function + "?" + str(returnValue) + "|").to_utf8_buffer());

func _save_to_temp_file(code: String) -> String:
	var temp_path: String = OS.get_user_data_dir() + "/temp.js";
	
	var file = FileAccess.open(temp_path, FileAccess.WRITE);
	if file == null:
		return "ERROR";
	file.store_string(
"""import net from "node:net";

const client = net.createConnection({ port: 5000 }, async () => {
	const _waitForPlayer = () =>
		new Promise((resolve) =>
			client.on("data", (data) =>
				data
					.toString()
					.split("|")
					.forEach(token => {
						let action = token.split(":")[ 0 ];
						let value = token.split(":")[ 1 ];
						console.log(Buffer.from(action, "utf8"))
						console.log(action, action == "status");
						console.log(value, value == "ready")
						
						if (action === "status" && value === "ready") resolve();
					})
			)
		);
	
	const _waitForReturn = (functionName) =>
		new Promise((resolve) => {
			client.on("data", (data) =>
				data
					.toString()
					.split("|")
					.forEach(token => {
						let action = token.split(":")[ 0 ];
						let value = token.split(":")[ 1 ];
						
						if (action != "return") return;
						
						let returnFunction = value.split("?")[ 0 ];
						let returnValue = value.split("?")[ 1 ];
						
						if (returnFunction == functionName) resolve(returnValue);
					})
			)
		})
	
	const moveUp = async () => {
		client.write("call:move_up|");
		await _waitForPlayer();
	};
	const moveDown = async () => {
		client.write("call:move_down|");
		await _waitForPlayer();
	};
	const moveLeft = async () => {
		client.write("call:move_left|");
		await _waitForPlayer();
	};
	const moveRight = async () => {
		client.write("call:move_right|");
		await _waitForPlayer();
	};
	const log = (data) => {
		client.write(`call:log?${ data }|`);
	};
	const isFacingWall = async () => {
		client.write("call:is_facing_wall");
		return (await _waitForReturn("is_facing_wall")) === "true";
	}
	
	// start of client's code
	""" + "\n\t".join(code.split("\n")) + """
	// end of client's code
});"""
	);
	
	return temp_path;

func send_next_command() -> void:
	if client == null:
		return;
	client.put_data(("status:ready").to_utf8_buffer())

func instatiate_node_js(code: String, logger: Callable) -> void:
	_open_session();
	
	kill_node_js();
	var path: String = _save_to_temp_file(code);
	_nodePid = OS.create_process("node", [ path ]);
	_logger = logger;

func kill_node_js() -> void:
	if OS.is_process_running(_nodePid) and _nodePid != 0:
		OS.kill(_nodePid);
