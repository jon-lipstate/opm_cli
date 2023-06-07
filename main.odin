package opm_cli
import "./external/http/client"
import "./external/http"
import "core:encoding/json"

import "core:fmt"
main :: proc() {
	// NOTE: https seems borked
	url := "http://jsonplaceholder.typicode.com/posts"
	postData := JSON_Post{"Stuff", "this is a fake article", 42}
	res, err := post(url, postData);assert(err == nil)
	bodyRes, allocated, berr := client.response_body(&res)
	body := bodyRes.(http.Body_Plain)
	post_res: Post_Result
	um_err := json.unmarshal_string(body, &post_res)
	assert(um_err == nil)
	client.body_destroy(bodyRes, allocated)

	fmt.println(post_res)
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
