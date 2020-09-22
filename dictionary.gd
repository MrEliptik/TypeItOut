extends Node2D

var request_queue = Array()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func request(word):
	if $HTTPRequest.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED: 
		# Put request in queue
		request_queue.append(word)
	else:
		var url = "https://api.dictionaryapi.dev/api/v2/entries/en/" + str(word)
		print(url)
		$HTTPRequest.request(url)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	# Request result is here, request another
	var word = request_queue.pop_front()
	if word:
		request(word)
	
	if response_code != 200: 
		print(response_code, body.get_string_from_utf8())
		return
	
	var json = JSON.parse(body.get_string_from_utf8())
	
	if json.error != OK: 
		print(json.error)
		return
	
	#print(json.result)
	if typeof(json.result) == TYPE_ARRAY:
		print(json.result[0].get("meanings")[0].get("definitions")[0].get("definition"))
	else:
		print("unexpected results")
