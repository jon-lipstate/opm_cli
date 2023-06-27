package opm_cli
//
import "core:encoding/json"
import "./external/curl"
import "core:fmt"
import "core:strings"
import "core:runtime"
import "core:mem"

// todo: use a proper URI?
// todo: how to append auth-tokens etc
post_json :: proc(url: string, request_json: any, $T: typeid) -> (ret: T, code: int) {
	using curl
	url_cstr := strings.clone_to_cstring(url);defer delete(url_cstr)
	json_data, merr := json.marshal(request_json);assert(merr == nil)
	assert(len(json_data) > 0, "NO DATA IN BODY")
	defer delete(json_data)
	// json_cstr := strings.clone_to_cstring(json_data);defer delete(json_cstr)
	fmt.println("json_data", string(json_data))
	h := easy_init();defer easy_cleanup(h)

	headers: ^curl_slist
	headers = slist_append(nil, "content-type: application/json")
	headers = slist_append(headers, "Accept: application/json")
	headers = slist_append(headers, "charset: utf-8")
	defer slist_free_all(headers)

	easy_setopt(h, CURLoption.URL, url_cstr)
	easy_setopt(h, CURLoption.HTTPHEADER, headers)

	easy_setopt(h, CURLoption.POST, 1)
	easy_setopt(h, CURLoption.POSTFIELDS, &json_data[0])
	easy_setopt(h, CURLoption.POSTFIELDSIZE, len(json_data))

	easy_setopt(h, CURLoption.WRITEFUNCTION, write_callback)
	data := DataContext{nil, context}
	easy_setopt(h, .WRITEDATA, &data)

	result := easy_perform(h)
	if result != CURLcode.OK {
		fmt.println("Error occurred: ", result)
	} else {
		// fmt.println("DATA", string(data.data))
		fmt.println("OK!")
	}

	return
}

DataContext :: struct {
	data: []u8,
	ctx:  runtime.Context,
}

write_callback :: proc "c" (contents: rawptr, size: uint, nmemb: uint, userp: rawptr) -> uint {
	dc := transmute(^DataContext)userp
	context = dc.ctx
	total_size := size * nmemb
	content_str := transmute([^]u8)contents
	dc.data = make([]u8, int(total_size)) // <-- ALLOCATION
	mem.copy(&dc.data[0], content_str, int(total_size))
	return total_size
}
