extends Node2D

var req_queue = Array()

var words = Array()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func clear_queue():
	req_queue = Array()

func request(word):
	if $HTTPRequest.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED: 
		# Put request in queue
		req_queue.append(word)
	else:
		var url = "https://api.dictionaryapi.dev/api/v2/entries/en/" + str(word)
		print(url)
		$HTTPRequest.request(url)

func add_to_queue(word):
	# Put request in queue
	req_queue.append(word)

func request_queue():
	# Put request in queue
	var url = "https://api.dictionaryapi.dev/api/v2/entries/en/" + str(req_queue.pop_front())
	$HTTPRequest.request(url)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	# Request result is here, request another
	var word = req_queue.pop_front()
	if word:
		request(word)
	
	if response_code != 200: 
		print(response_code, body.get_string_from_utf8())
		return
	
	var json = JSON.parse(body.get_string_from_utf8())
	
	if json.error != OK: 
		print(json.error)
		return
	
	if typeof(json.result) == TYPE_ARRAY:
		var word_def = {
			"word":"",
			"definition":""
		}
		word_def["word"] = json.result[0].get("word")
		word_def["definition"] = json.result[0].get("meanings")[0].get("definitions")[0].get("definition")
		words.append(word_def)
		print(word_def)
	else:
		print("unexpected results")
		
	if req_queue.size() == 0:
		get_parent().get_node("CanvasLayer/PauseMenu").set_words(words)
