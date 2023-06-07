package opm_cli

import "./external/http/client"
import "core:fmt"

get :: proc(url: string) -> (response: client.Response, err: client.Error) {
	response, err = client.get(url)
	if err != nil {
		fmt.printf("Request failed: %s", err)
		return
	}
	// defer client.response_destroy(&res)

	// fmt.printf("Status: %s\n", res.status)
	// fmt.printf("Headers: %v\n", res.headers)
	// fmt.printf("Cookies: %v\n", res.cookies)
	// body, alloc_occurred, berr := client.response_body(&res)
	// if berr != nil {
	// 	fmt.printf("Error retrieving response body: %s", berr)
	// 	return
	// }
	// defer client.body_destroy(body, alloc_occurred)

	// fmt.println(body)
	return
}
// todo: use a proper URI?
// todo: how to append auth-tokens etc
post :: proc(url: string, json: any) -> (response: client.Response, err: client.Error) {
	req: client.Request
	client.request_init(&req, .Post)
	defer client.request_destroy(&req)

	if err := client.with_json(&req, json); err != nil {
		fmt.printf("JSON error: %s", err)
		return
	}
	req.headers["method"] = "POST"
	// fmt.println(string(req.body.buf[:]))
	// fmt.println(req)

	response, err = client.request(url, &req)
	if err != nil {
		fmt.printf("Request failed: %s", err)
		return
	}
	return
}
