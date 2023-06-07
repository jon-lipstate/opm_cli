package opm_cli
import "./external/http/client"
import "./external/http"
import "core:encoding/json"
import "core:mem"
import "core:fmt"

main :: proc() {
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)
	_main()
	for _, leak in track.allocation_map do fmt.printf("%v leaked %v bytes\n", leak.location, leak.size)
	for bad_free in track.bad_free_array do fmt.printf("%v allocation %p was freed badly\n", bad_free.location, bad_free.memory)
}

_main :: proc() {
	// NOTE: https seems borked
	url := "http://jsonplaceholder.typicode.com/posts"
	postData := JSON_Post{"Stuff", "this is a fake article", 42}
	// res, err := post(url, postData);assert(err == nil)
	// bodyRes, allocated, berr := client.response_body(&res)
	// body := bodyRes.(http.Body_Plain)
	// post_res: Post_Result
	// um_err := json.unmarshal_string(body, &post_res)
	// assert(um_err == nil)
	// client.body_destroy(bodyRes, allocated)

	// fmt.println(post_res)
	res, err := post_json(url, postData, Post_Result)
	fmt.println(res)
	delete(res.body)
	delete(res.title)
}

JSON_Post :: struct {
	title:  string,
	body:   string,
	userId: int,
}
Post_Result :: struct {
	title:  string,
	body:   string,
	userId: int,
	id:     int,
}
// fetch('https://jsonplaceholder.typicode.com/posts', {
//     method: 'POST',
//     body: JSON.stringify({
//       title: new_title,
//       body: new_body,
//       userId: userid
//     }),
//     headers: {
//       "Content-type": "application/json; charset=UTF-8"
//     }
//   })
