package opm_cli
import "./external/http"
import "core:encoding/json"
import "./external/http/client"
import "core:fmt"

get_json :: proc(url: string, $T: typeid) -> (response: client.Response, err: client.Error) {
	response, err = client.get(url)
	if err != nil {
		fmt.printf("Request failed: %s", err)
		return
	}
	return
}
// todo: use a proper URI?
// todo: how to append auth-tokens etc
post_json :: proc(url: string, request_json: any, $T: typeid) -> (ret: T, code: http.Status) {
	req: client.Request
	client.request_init(&req, .Post)
	defer client.request_destroy(&req)
	if err := client.with_json(&req, request_json); err != nil {
		fmt.printf("JSON error: %s", err)
		return
	}
	res, er := client.request(url, &req);assert(er == nil)
	defer client.response_destroy(&res)

	bodyRes, allocated, berr := client.response_body(&res)
	body, ok := bodyRes.(http.Body_Plain)
	code = res.status
	if ok {
		um_err := json.unmarshal_string(body, &ret)
		if um_err != nil {
			fmt.println("failed to parse body", body)
		}
		client.body_destroy(bodyRes, allocated)
	} else {
		fmt.println("!ok - BODY_RES", bodyRes)
	}

	return
}
