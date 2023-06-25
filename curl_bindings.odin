package opm_cli
//
import "core:dynlib"
//
post_json_curl :: proc(str: string, allocator := context.allocator) -> string {

	curl := init_curl("./libcurl-x64.dll");defer shutdown_curl(&curl)
	headers: ^SList
	headers = curl.slist_append(headers, cstring("Content-Type: application/json"))

	curl.setopt(curl.h, CurlOption.SslVerifypeer, 0)
	curl.setopt(curl.h, CurlOption.URL, url)
	curl.setopt(curl.h, CurlOption.Httpheader, headers)
	curl.setopt(curl.h, CurlOption.Post, 1)
	curl.setopt(curl.h, CurlOption.Postfields, json_data)
	curl.setopt(curl.h, CurlOption.Postfieldsize, len(json_data))
	result := curl.perform(curl.h)
	if result != CurlCode.Ok {
		fmt.println("Curl Error Occurred: ", result)
		return "error"
	} else {
		// Get the response data
		response_data: [^]u8
		curl.get_info(curl.h, CurlInfo.ResponseCode, &response_data)
		res := strings.clone_from_cstring(cstring(response_data), allocator)
		fmt.println(res)
		return res
	}
}
//
SList :: struct {}
Curl :: struct {
	dll:          dynlib.Library,
	h:            rawptr,
	init:         proc() -> rawptr,
	cleanup:      proc(h: rawptr),
	setopt:       proc "c" (h: rawptr, option: CurlOption, #c_vararg params: ..any),
	perform:      proc(h: rawptr) -> CurlCode,
	get_info:     proc "c" (h: rawptr, info: CurlInfo, #c_vararg params: ..any) -> CurlCode,
	reset:        proc(h: rawptr) -> CurlCode,
	recv:         proc(h: rawptr, buffer: rawptr, buflen: i64, n: ^i64) -> CurlCode,
	send:         proc(h: rawptr, buffer: rawptr, buflen: i64, n: ^i64) -> CurlCode,
	slist_append: proc(sl: ^SList, str: cstring) -> ^SList,
}
shutdown_curl :: proc(curl: ^Curl) {
	curl.cleanup(curl.h)
	dynlib.unload_library(curl.dll)
}
init_curl :: proc(path: string) -> Curl {
	c := Curl{}
	curl_dll, ok := dynlib.load_library(path);assert(ok)
	c.dll = curl_dll
	//
	init := dynlib.symbol_address(curl_dll, "curl_easy_init")
	cleanup := dynlib.symbol_address(curl_dll, "curl_easy_cleanup")
	setopt := dynlib.symbol_address(curl_dll, "curl_easy_setopt")
	perform := dynlib.symbol_address(curl_dll, "curl_easy_perform")
	get_info := dynlib.symbol_address(curl_dll, "curl_easy_get_info")
	reset := dynlib.symbol_address(curl_dll, "curl_easy_reset")
	recv := dynlib.symbol_address(curl_dll, "curl_easy_recv")
	send := dynlib.symbol_address(curl_dll, "curl_easy_send")
	slist_append := dynlib.symbol_address(curl_dll, "curl_slist_append")
	//
	c.init = auto_cast init
	c.cleanup = auto_cast cleanup
	c.setopt = auto_cast setopt
	c.perform = auto_cast perform
	c.get_info = auto_cast get_info
	c.reset = auto_cast reset
	c.recv = auto_cast recv
	c.send = auto_cast send
	c.slist_append = auto_cast slist_append
	c.h = c.init();assert(c.h != nil)
	//
	return c
}


// curl_easy_header
// curl_easy_nextheader
// curl_easy_option_by_id
// curl_easy_option_by_name
// curl_easy_option_next
// curl_easy_pause
// curl_easy_recv
// curl_easy_reset
// curl_easy_send
// curl_easy_setopt
// curl_easy_strerror
// curl_easy_unescape
// curl_easy_upkeep
// curl_escape
// curl_formadd
// curl_formfree
// curl_formget
// curl_free
// curl_getdate
// curl_getenv
// curl_global_cleanup
// curl_global_init
// curl_global_init_mem
// curl_global_sslset
// curl_maprintf
// curl_mfprintf
// curl_mime_addpart
// curl_mime_data
// curl_mime_data_cb
// curl_mime_encoder
// curl_mime_filedata
// curl_mime_filename
// curl_mime_free
// curl_mime_headers
// curl_mime_init
// curl_mime_name
// curl_mime_subparts
// curl_mime_type
// curl_mprintf
// curl_msnprintf
// curl_msprintf
// curl_multi_add_handle
// curl_multi_assign
// curl_multi_cleanup
// curl_multi_fdset
// curl_multi_info_read
// curl_multi_init
// curl_multi_perform
// curl_multi_poll
// curl_multi_remove_handle
// curl_multi_setopt
// curl_multi_socket
// curl_multi_socket_action
// curl_multi_socket_all
// curl_multi_strerror
// curl_multi_timeout
// curl_multi_wait
// curl_multi_wakeup
// curl_mvaprintf
// curl_mvfprintf
// curl_mvprintf
// curl_mvsnprintf
// curl_mvsprintf
// curl_pushheader_byname
// curl_pushheader_bynum
// curl_share_cleanup
// curl_share_init
// curl_share_setopt
// curl_share_strerror
// curl_slist_append
// curl_slist_free_all
// curl_strequal
// curl_strnequal
// curl_unescape
// curl_url
// curl_url_cleanup
// curl_url_dup
// curl_url_get
// curl_url_set
// curl_url_strerror
// curl_version
// curl_version_info
// curl_ws_meta
// curl_ws_recv
// curl_ws_send


CurlCode :: enum i32 {
	Ok = 0,
	UnsupportedProtocol, /* 1 */
	FailedInit, /* 2 */
	URLMalformat, /* 3 */
	NotBuiltIn, /* 4 - [was obsoleted in August 2007 for 7.17.0, reused in April 2011 for 7.21.5] */
	CouldntResolveProxy, /* 5 */
	CouldntResolveHost, /* 6 */
	CouldntConnect, /* 7 */
	WeirdServerReply, /* 8 */
	RemoteAccessDenied, /* 9 a service was denied by the server due to lack of access - when login fails this is not returned. */
	FtpAcceptFailed, /* 10 - [was obsoleted in April 2006 for 7.15.4, reused in Dec 2011 for 7.24.0]*/
	FtpWeirdPassReply, /* 11 */
	FtpAcceptTimeout, /* 12 - timeout occurred accepting server [was obsoleted in August 2007 for 7.17.0, reused in Dec 2011 for 7.24.0]*/
	FtpWeirdPasvReply, /* 13 */
	FtpWeird227Format, /* 14 */
	FtpCantGetHost, /* 15 */
	Http2, /* 16 - A problem in the http2 framing layer. [was obsoleted in August 2007 for 7.17.0, reused in July 2014 for 7.38.0] */
	FtpCouldntSetType, /* 17 */
	PartialFile, /* 18 */
	FtpCouldntRetrFile, /* 19 */
	Obsolete20, /* 20 - NOT USED */
	QuoteError, /* 21 - quote command failure */
	HTTPReturnedError, /* 22 */
	WriteError, /* 23 */
	Obsolete24, /* 24 - NOT USED */
	UploadFailed, /* 25 - failed upload "command" */
	ReadError, /* 26 - couldn't open/read from file */
	OutOfMemory, /* 27 - OutOfMemory may sometimes indicate a conversion error instead of a memory allocation error if CURL_DOES_CONVERSIONS is defined */
	OperationTimedout, /* 28 - the timeout time was reached */
	Obsolete29, /* 29 - NOT USED */
	FtpPortFailed, /* 30 - FTP PORT operation failed */
	FtpCouldntUseRest, /* 31 - the REST command failed */
	Obsolete32, /* 32 - NOT USED */
	RangeError, /* 33 - RANGE "command" didn't work */
	HTTPPostError, /* 34 */
	SslConnectError, /* 35 - wrong when connecting with SSL */
	BadDownloadResume, /* 36 - couldn't resume download */
	FileCouldntReadFile, /* 37 */
	LdapCannotBind, /* 38 */
	LdapSearchFailed, /* 39 */
	Obsolete40, /* 40 - NOT USED */
	FunctionNotFound, /* 41 - NOT USED starting with 7.53.0 */
	AbortedByCallback, /* 42 */
	BadFunctionArgument, /* 43 */
	Obsolete44, /* 44 - NOT USED */
	InterfaceFailed, /* 45 - CURLOPT_INTERFACE failed */
	Obsolete46, /* 46 - NOT USED */
	TooManyRedirects, /* 47 - catch endless re-direct loops */
	UnknownOption, /* 48 - User specified an unknown option */
	TelnetOptionSyntax, /* 49 - Malformed telnet option */
	Obsolete50, /* 50 - NOT USED */
	PeerFailedVerification, /* 51 - peer's certificate or fingerprint wasn't verified fine */
	GotNothing, /* 52 - when this is a specific error */
	SslEngineNotfound, /* 53 - SSL crypto engine not found */
	SslEngineSetfailed, /* 54 - can not set SSL crypto engine as default */
	SendError, /* 55 - failed sending network data */
	RecvError, /* 56 - failure in receiving network data */
	Obsolete57, /* 57 - NOT IN USE */
	SslCertproblem, /* 58 - problem with the local certificate */
	SslCipher, /* 59 - couldn't use specified cipher */
	SslCacert, /* 60 - problem with the CA cert (path?) */
	BadContentEncoding, /* 61 - Unrecognized/bad encoding */
	LdapInvalidURL, /* 62 - Invalid LDAP URL */
	FilesizeExceeded, /* 63 - Maximum file size exceeded */
	UseSslFailed, /* 64 - Requested FTP SSL level failed */
	SendFailRewind, /* 65 - Sending the data requires a rewind that failed */
	SslEngineInitfailed, /* 66 - failed to initialise ENGINE */
	LoginDenied, /* 67 - user, password or similar was not accepted and we failed to login */
	TftpNotfound, /* 68 - file not found on server */
	TftpPerm, /* 69 - permission problem on server */
	RemoteDiskFull, /* 70 - out of disk space on server */
	TftpIllegal, /* 71 - Illegal TFTP operation */
	TftpUnknownid, /* 72 - Unknown transfer ID */
	RemoteFileExists, /* 73 - File already exists */
	TftpNosuchuser, /* 74 - No such user */
	ConvFailed, /* 75 - conversion failed */
	ConvReqd, /* 76 - caller must register conversion callbacks using curl_easy_setopt options CURLOPT_CONV_FROM_NETWORK_FUNCTION, CURLOPT_CONV_TO_NETWORK_FUNCTION, and CURLOPT_CONV_FROM_UTF8_FUNCTION */
	SslCacertBadfile, /* 77 - could not load CACERT file, missing or wrong format */
	RemoteFileNotFound, /* 78 - remote file not found */
	Ssh, /* 79 - error from the SSH layer, somewhat generic so the error message will be of interest when this has happened */
	SslShutdownFailed, /* 80 - Failed to shut down the SSL connection */
	Again, /* 81 - socket is not ready for send/recv, wait till it's ready and try again (Added in 7.18.2) */
	SslCrlBadfile, /* 82 - could not load CRL file, missing or wrong format (Added in 7.19.0) */
	SslIssuerError, /* 83 - Issuer check failed.  (Added in 7.19.0) */
	FtpPretFailed, /* 84 - a PRET command failed */
	RtspCseqError, /* 85 - mismatch of RTSP CSeq numbers */
	RtspSessionError, /* 86 - mismatch of RTSP Session Ids */
	FtpBadFileList, /* 87 - unable to parse FTP file list */
	ChunkFailed, /* 88 - chunk callback reported error */
	NoConnectionAvailable, /* 89 - No connection available, the session will be queued */
	SslPinnedpubkeynotmatch, /* 90 - specified pinned public key did not  match */
	SslInvalidcertstatus, /* 91 - invalid certificate status */
	Http2Stream, /* 92 - stream error in HTTP/2 framing layer */
	CurlLast, /* never use! */
}

CURLINFO_STRING :: 0x100000
CURLINFO_LONG :: 0x200000
CURLINFO_DOUBLE :: 0x300000
CURLINFO_SLIST :: 0x400000
CURLINFO_PTR :: 0x400000
CURLINFO_SOCKET :: 0x500000
CURLINFO_MASK :: 0x0fffff
CURLINFO_TYPEMASK :: 0xf00000

CurlInfo :: enum i32 {
	None                  = 0, //Never use this
	EffectiveURL          = CURLINFO_STRING + 1,
	ResponseCode          = CURLINFO_LONG + 2,
	TotalTime             = CURLINFO_DOUBLE + 3,
	NamelookupTime        = CURLINFO_DOUBLE + 4,
	ConnectTime           = CURLINFO_DOUBLE + 5,
	PretransferTime       = CURLINFO_DOUBLE + 6,
	SizeUpload            = CURLINFO_DOUBLE + 7,
	SizeDownload          = CURLINFO_DOUBLE + 8,
	SpeedDownload         = CURLINFO_DOUBLE + 9,
	SpeedUpload           = CURLINFO_DOUBLE + 10,
	HeaderSize            = CURLINFO_LONG + 11,
	RequestSize           = CURLINFO_LONG + 12,
	SslVerifyresult       = CURLINFO_LONG + 13,
	Filetime              = CURLINFO_LONG + 14,
	ContentLengthDownload = CURLINFO_DOUBLE + 15,
	ContentLengthUpload   = CURLINFO_DOUBLE + 16,
	StarttransferTime     = CURLINFO_DOUBLE + 17,
	ContentType           = CURLINFO_STRING + 18,
	RedirectTime          = CURLINFO_DOUBLE + 19,
	RedirectCount         = CURLINFO_LONG + 20,
	Private               = CURLINFO_STRING + 21,
	HTTPConnectcode       = CURLINFO_LONG + 22,
	HttpauthAvail         = CURLINFO_LONG + 23,
	ProxyauthAvail        = CURLINFO_LONG + 24,
	OsErrno               = CURLINFO_LONG + 25,
	NumConnects           = CURLINFO_LONG + 26,
	SslEngines            = CURLINFO_SLIST + 27,
	Cookielist            = CURLINFO_SLIST + 28,
	Lastsocket            = CURLINFO_LONG + 29,
	FtpEntryPath          = CURLINFO_STRING + 30,
	RedirectURL           = CURLINFO_STRING + 31,
	PrimaryIp             = CURLINFO_STRING + 32,
	AppconnectTime        = CURLINFO_DOUBLE + 33,
	Certinfo              = CURLINFO_PTR + 34,
	ConditionUnmet        = CURLINFO_LONG + 35,
	RtspSessionID         = CURLINFO_STRING + 36,
	RtspClientCseq        = CURLINFO_LONG + 37,
	RtspServerCseq        = CURLINFO_LONG + 38,
	RtspCseqRecv          = CURLINFO_LONG + 39,
	PrimaryPort           = CURLINFO_LONG + 40,
	LocalIp               = CURLINFO_STRING + 41,
	LocalPort             = CURLINFO_LONG + 42,
	TlsSession            = CURLINFO_PTR + 43,
	Activesocket          = CURLINFO_SOCKET + 44,
	TlsSslPtr             = CURLINFO_PTR + 45,
	HTTPVersion           = CURLINFO_LONG + 46,
	ProxySslVerifyresult  = CURLINFO_LONG + 47,
	Protocol              = CURLINFO_LONG + 48,
	Scheme                = CURLINFO_STRING + 49,
	/* Fill in new entries below here! */
	Lastone               = 49,
}


CURLOPTTYPE_LONG :: 0
CURLOPTTYPE_OBJECTPOINT :: 10000
CURLOPTTYPE_STRINGPOINT :: 10000
CURLOPTTYPE_FUNCTIONPOINT :: 20000
CURLOPTTYPE_OFF_T :: 30000

CurlOption :: enum i32 {
	/* This is the FILE * or void * the regular output should be written to. */
	Writedata = CURLOPTTYPE_OBJECTPOINT + 1,
	/* The full URL to get/put */
	URL = CURLOPTTYPE_STRINGPOINT + 2,
	/* Port number to connect to, if other than default. */
	Port = CURLOPTTYPE_LONG + 3,
	/* Name of proxy to use. */
	Proxy = CURLOPTTYPE_STRINGPOINT + 4,
	/* "user:password;options" to use when fetching. */
	Userpwd = CURLOPTTYPE_STRINGPOINT + 5,
	/* "user:password" to use with proxy. */
	Proxyuserpwd = CURLOPTTYPE_STRINGPOINT + 6,
	/* Range to get, specified as an ASCII string. */
	Range = CURLOPTTYPE_STRINGPOINT + 7,
	/* not used */
	/* Specified file stream to upload from (use as input): */
	Readdata = CURLOPTTYPE_OBJECTPOINT + 9,
	/* Buffer to receive error messages in, must be at least CURL_ERROR_SIZE
      * bytes big. If this is not used, error messages go to stderr instead: */
	Errorbuffer = CURLOPTTYPE_OBJECTPOINT + 10,
	/* Function that will be called to store the output (instead of fwrite). The
      * parameters will use fwrite() syntax, make sure to follow them. */
	Writefunction = CURLOPTTYPE_FUNCTIONPOINT + 11,
	/* Function that will be called to read the input (instead of fread). The
      * parameters will use fread() syntax, make sure to follow them. */
	Readfunction = CURLOPTTYPE_FUNCTIONPOINT + 12,
	/* Time-out the read operation after this amount of seconds */
	Timeout = CURLOPTTYPE_LONG + 13,
	/* If the CURLOPT_INFILE is used, this can be used to inform libcurl about
      * how large the file being sent really is. That allows better error
      * checking and better verifies that the upload was successful. -1 means
      * unknown size.
      *
      * For large file support, there is also a _LARGE version of the key
      * which takes an off_t type, allowing platforms with larger off_t
      * sizes to handle larger files.  See below for INFILESIZE_LARGE.
      */
	Infilesize = CURLOPTTYPE_LONG + 14,
	/* POST static input fields. */
	Postfields = CURLOPTTYPE_OBJECTPOINT + 15,
	/* Set the referrer page (needed by some CGIs) */
	Referer = CURLOPTTYPE_STRINGPOINT + 16,
	/* Set the FTP PORT string (interface name, named or numerical IP address)
        Use i.e '-' to use default address. */
	Ftpport = CURLOPTTYPE_STRINGPOINT + 17,
	/* Set the User-Agent string (examined by some CGIs) */
	Useragent = CURLOPTTYPE_STRINGPOINT + 18,
	/* If the download receives less than "low speed limit" bytes/second
      * during "low speed time" seconds, the operations is aborted.
      * You could i.e if you have a pretty high speed connection, abort if
      * it is less than 2000 bytes/sec during 20 seconds.
      */
	/* Set the "low speed limit" */
	LowSpeedLimit = CURLOPTTYPE_LONG + 19,
	/* Set the "low speed time" */
	LowSpeedTime = CURLOPTTYPE_LONG + 20,
	/* Set the continuation offset.
      *
      * Note there is also a _LARGE version of this key which uses
      * off_t types, allowing for large file offsets on platforms which
      * use larger-than-32-bit off_t's.  Look below for RESUME_FROM_LARGE.
      */
	ResumeFrom = CURLOPTTYPE_LONG + 21,
	/* Set cookie in request: */
	Cookie = CURLOPTTYPE_STRINGPOINT + 22,
	/* This points to a linked list of headers, struct curl_slist kind. This
        list is also used for RTSP (in spite of its name) */
	Httpheader = CURLOPTTYPE_OBJECTPOINT + 23,
	/* This points to a linked list of post entries, struct curl_httppost */
	Httppost = CURLOPTTYPE_OBJECTPOINT + 24,
	/* name of the file keeping your private SSL-certificate */
	Sslcert = CURLOPTTYPE_STRINGPOINT + 25,
	/* password for the SSL or SSH private key */
	Keypasswd = CURLOPTTYPE_STRINGPOINT + 26,
	/* send TYPE parameter? */
	Crlf = CURLOPTTYPE_LONG + 27,
	/* send linked-list of QUOTE commands */
	Quote = CURLOPTTYPE_OBJECTPOINT + 28,
	/* send FILE * or void * to store headers to, if you use a callback it
        is simply passed to the callback unmodified */
	Headerdata = CURLOPTTYPE_OBJECTPOINT + 29,
	/* point to a file to read the initial cookies from, also enables
        "cookie awareness" */
	Cookiefile = CURLOPTTYPE_STRINGPOINT + 31,
	/* What version to specifically try to use.
        See CURL_SSLVERSION defines below. */
	Sslversion = CURLOPTTYPE_LONG + 32,
	/* What kind of HTTP time condition to use, see defines */
	Timecondition = CURLOPTTYPE_LONG + 33,
	/* Time to use with the above condition. Specified in number of seconds
        since 1 Jan 1970 */
	Timevalue = CURLOPTTYPE_LONG + 34,
	/*35                                                                  = OBSOLETE */
	/* Custom request, for customizing the get command like
        HTTP: DELETE, TRACE and others
        FTP: to use a different list command
        */
	Customrequest = CURLOPTTYPE_STRINGPOINT + 36,
	/* FILE handle to use instead of stderr */
	Stderr = CURLOPTTYPE_OBJECTPOINT + 37,
	/* 38 is not used */
	/* send linked-list of post-transfer QUOTE commands */
	Postquote = CURLOPTTYPE_OBJECTPOINT + 39,
	Obsolete40 = CURLOPTTYPE_OBJECTPOINT + 40, /* OBSOLETE, do not use! */
	Verbose = CURLOPTTYPE_LONG + 41, /* talk a lot */
	Header = CURLOPTTYPE_LONG + 42, /* throw the header out too */
	Noprogress = CURLOPTTYPE_LONG + 43, /* shut off the progress meter */
	Nobody = CURLOPTTYPE_LONG + 44, /* use HEAD to get http document */
	Failonerror = CURLOPTTYPE_LONG + 45, /* no output on http erro  codes = 400 */
	Upload = CURLOPTTYPE_LONG + 46, /* this is an upload */
	Post = CURLOPTTYPE_LONG + 47, /* HTTP POST method */
	Dirlistonly = CURLOPTTYPE_LONG + 48, /* bare names when listing directories */
	Append = CURLOPTTYPE_LONG + 50, /* Append instead of overwrite on upload! */
	/* Specify whether to read the user+password from the .netrc or the URL.
      * This must be one of the CURL_NETRC_* enums below. */
	Netrc = CURLOPTTYPE_LONG + 51,
	Followlocation = CURLOPTTYPE_LONG + 52, /* use Location: Luke! */
	Transfertext = CURLOPTTYPE_LONG + 53, /* transfer data in text/ASCII format */
	Put = CURLOPTTYPE_LONG + 54, /* HTTP PUT */
	/*55                                                                  = OBSOLETE */
	/* DEPRECATED
      * Function that will be called instead of the internal progress display
      * function. This function should be defined as the curl_progress_callback
      * prototype defines. */
	Progressfunction = CURLOPTTYPE_FUNCTIONPOINT + 56,
	/* Data passed to the CURLOPT_PROGRESSFUNCTION and CURLOPT_XFERINFOFUNCTION
        callbacks */
	Progressdata = CURLOPTTYPE_OBJECTPOINT + 57,
	//#define CURLOPT_XFERINFODATA CURLOPT_PROGRESSDATA
	/* We want the referrer field set automatically when following locations */
	Autoreferer = CURLOPTTYPE_LONG + 58,
	/* Port of the proxy, can be set in the proxy string as well with:
        "[host]:[port]" */
	Proxyport = CURLOPTTYPE_LONG + 59,
	/* size of the POST input data, if strlen() is not good to use */
	Postfieldsize = CURLOPTTYPE_LONG + 60,
	/* tunnel non-http operations through a HTTP proxy */
	Httpproxytunnel = CURLOPTTYPE_LONG + 61,
	/* Set the interface string to use as outgoing network interface */
	Interface = CURLOPTTYPE_STRINGPOINT + 62,
	/* Set the krb4/5 security level, this also enables krb4/5 awareness.  This
      * is a string, 'clear', 'safe', 'confidential' or 'private'.  If the string
      * is set but doesn't match one of these, 'private' will be used.  */
	Krblevel = CURLOPTTYPE_STRINGPOINT + 63,
	/* Set if we should verify the peer in ssl handshake, set 1 to verify. */
	SslVerifypeer = CURLOPTTYPE_LONG + 64,
	/* The CApath or CAfile used to validate the peer certificate
        this option is used only if SSL_VERIFYPEER is true */
	Cainfo = CURLOPTTYPE_STRINGPOINT + 65,
	/*66                                                                  = OBSOLETE */
	/*67                                                                  = OBSOLETE */
	/* Maximum number of http redirects to follow */
	Maxredirs = CURLOPTTYPE_LONG + 68,
	/* Pass a long set to 1 to get the date of the requested document (if
        possible)! Pass a zero to shut it off. */
	Filetime = CURLOPTTYPE_LONG + 69,
	/* This points to a linked list of telnet options */
	Telnetoptions = CURLOPTTYPE_OBJECTPOINT + 70,
	/* Max amount of cached alive connections */
	Maxconnects = CURLOPTTYPE_LONG + 71,
	Obsolete72 = CURLOPTTYPE_LONG + 72, /* OBSOLETE, do not use! */
	/*73                                                                  = OBSOLETE */
	/* Set to explicitly use a new connection for the upcoming transfer.
        Do not use this unless you're absolutely sure of this, as it makes the
        operation slower and is less friendly for the network. */
	FreshConnect = CURLOPTTYPE_LONG + 74,
	/* Set to explicitly forbid the upcoming transfer's connection to be re-used
        when done. Do not use this unless you're absolutely sure of this, as it
        makes the operation slower and is less friendly for the network. */
	ForbidReuse = CURLOPTTYPE_LONG + 75,
	/* Set to a file name that contains random data for libcurl to use to
        seed the random engine when doing SSL connects. */
	RandomFile = CURLOPTTYPE_STRINGPOINT + 76,
	/* Set to the Entropy Gathering Daemon socket pathname */
	Egdsocket = CURLOPTTYPE_STRINGPOINT + 77,
	/* Time-out connect operations after this amount of seconds, if connects are
        OK within this time, then fine... This only aborts the connect phase. */
	Connecttimeout = CURLOPTTYPE_LONG + 78,
	/* Function that will be called to store headers (instead of fwrite). The
      * parameters will use fwrite() syntax, make sure to follow them. */
	Headerfunction = CURLOPTTYPE_FUNCTIONPOINT + 79,
	/* Set this to force the HTTP request to get back to GET. Only really usable
        if POST, PUT or a custom request have been used first.
      */
	Httpget = CURLOPTTYPE_LONG + 80,
	/* Set if we should verify the Common name from the peer certificate in ssl
      * handshake, set 1 to check existence, 2 to ensure that it matches the
      * provided hostname. */
	SslVerifyhost = CURLOPTTYPE_LONG + 81,
	/* Specify which file name to write all known cookies in after completed
        operation. Set file name to "-" (dash) to make it go to stdout. */
	Cookiejar = CURLOPTTYPE_STRINGPOINT + 82,
	/* Specify which SSL ciphers to use */
	SslCipherList = CURLOPTTYPE_STRINGPOINT + 83,
	/* Specify which HTTP version to use! This must be set to one of the
        CURL_HTTP_VERSION* enums set below. */
	HTTPVersion = CURLOPTTYPE_LONG + 84,
	/* Specifically switch on or off the FTP engine's use of the EPSV command. By
        default, that one will always be attempted before the more traditional
        PASV command. */
	FtpUseEpsv = CURLOPTTYPE_LONG + 85,
	/* type of the file keeping your SSL-certificate ("DER", "PEM", "ENG") */
	Sslcerttype = CURLOPTTYPE_STRINGPOINT + 86,
	/* name of the file keeping your private SSL-key */
	Sslkey = CURLOPTTYPE_STRINGPOINT + 87,
	/* type of the file keeping your private SSL-key ("DER", "PEM", "ENG") */
	Sslkeytype = CURLOPTTYPE_STRINGPOINT + 88,
	/* crypto engine for the SSL-sub system */
	Sslengine = CURLOPTTYPE_STRINGPOINT + 89,
	/* set the crypto engine for the SSL-sub system as default
        the param has no meaning...
      */
	SslengineDefault = CURLOPTTYPE_LONG + 90,
	/* Non-zero value means to use the global dns cache */
	DnsUseGlobalCache = CURLOPTTYPE_LONG + 91, /* DEPRECATED, do not use! */
	/* DNS cache timeout */
	DnsCacheTimeout = CURLOPTTYPE_LONG + 92,
	/* send linked-list of pre-transfer QUOTE commands */
	Prequote = CURLOPTTYPE_OBJECTPOINT + 93,
	/* set the debug function */
	Debugfunction = CURLOPTTYPE_FUNCTIONPOINT + 94,
	/* set the data for the debug function */
	Debugdata = CURLOPTTYPE_OBJECTPOINT + 95,
	/* mark this as start of a cookie session */
	Cookiesession = CURLOPTTYPE_LONG + 96,
	/* The CApath directory used to validate the peer certificate
        this option is used only if SSL_VERIFYPEER is true */
	Capath = CURLOPTTYPE_STRINGPOINT + 97,
	/* Instruct libcurl to use a smaller receive buffer */
	Buffersize = CURLOPTTYPE_LONG + 98,
	/* Instruct libcurl to not use any signal/alarm handlers, even when using
        timeouts. This option is useful for multi-threaded applications.
        See libcurl-the-guide for more background information. */
	Nosignal = CURLOPTTYPE_LONG + 99,
	/* Provide a CURLShare for mutexing non-ts data */
	Share = CURLOPTTYPE_OBJECTPOINT + 100,
	/* indicates type of proxy. accepted values are CURLPROXY_HTTP (default),
        CURLPROXY_HTTPS, CURLPROXY_SOCKS4, CURLPROXY_SOCKS4A and
        CURLPROXY_SOCKS5. */
	Proxytype = CURLOPTTYPE_LONG + 101,
	/* Set the Accept-Encoding string. Use this to tell a server you would like
        the response to be compressed. Before 7.21.6, this was known as
        CURLOPT_ENCODING */
	AcceptEncoding = CURLOPTTYPE_STRINGPOINT + 102,
	/* Set pointer to private data */
	Private = CURLOPTTYPE_OBJECTPOINT + 103,
	/* Set aliases for HTTP 200 in the HTTP Response header */
	Http200aliases = CURLOPTTYPE_OBJECTPOINT + 104,
	/* Continue to send authentication (user+password) when following locations,
        even when hostname changed. This can potentially send off the name
        and password to whatever host the server decides. */
	UnrestrictedAuth = CURLOPTTYPE_LONG + 105,
	/* Specifically switch on or off the FTP engine's use of the EPRT command (
        it also disables the LPRT attempt). By default, those ones will always be
        attempted before the good old traditional PORT command. */
	FtpUseEprt = CURLOPTTYPE_LONG + 106,
	/* Set this to a bitmask value to enable the particular authentications
        methods you like. Use this in combination with CURLOPT_USERPWD.
        Note that setting multiple bits may cause extra network round-trips. */
	Httpauth = CURLOPTTYPE_LONG + 107,
	/* Set the ssl context callback function, currently only for OpenSSL ssl_ctx
        in second argument. The function must be matching the
        curl_ssl_ctx_callback proto. */
	SslCtxFunction = CURLOPTTYPE_FUNCTIONPOINT + 108,
	/* Set the userdata for the ssl context callback function's third
        argument */
	SslCtxData = CURLOPTTYPE_OBJECTPOINT + 109,
	/* FTP Option that causes missing dirs to be created on the remote server.
        In 7.19.4 we introduced the convenience enums for this option using the
        CURLFTP_CREATE_DIR prefix.
     */
	FtpCreateMissingDirs = CURLOPTTYPE_LONG + 110,
	/* Set this to a bitmask value to enable the particular authentications
        methods you like. Use this in combination with CURLOPT_PROXYUSERPWD.
        Note that setting multiple bits may cause extra network round-trips. */
	Proxyauth = CURLOPTTYPE_LONG + 111,
	/* FTP option that changes the timeout, in seconds, associated with
        getting a response.  This is different from transfer timeout time and
        essentially places a demand on the FTP server to acknowledge commands
        in a timely manner. */
	FtpResponseTimeout = CURLOPTTYPE_LONG + 112,
	//#define CURLOPT_SERVER_RESPONSE_TIMEOUT CURLOPT_FTP_RESPONSE_TIMEOUT
	/* Set this option to one of the CURL_IPRESOLVE_* defines (see below) to
        tell libcurl to resolve names to those IP versions only. This only has
        affect on systems with support for more than one, i.e IPv4 _and_ IPv6. */
	Ipresolve = CURLOPTTYPE_LONG + 113,
	/* Set this option to limit the size of a file that will be downloaded from
        an HTTP or FTP server.
   
        Note there is also _LARGE version which adds large file support for
        platforms which have larger off_t sizes.  See MAXFILESIZE_LARGE below. */
	Maxfilesize = CURLOPTTYPE_LONG + 114,
	/* See the comment for INFILESIZE above, but in short, specifies
      * the size of the file being uploaded.  -1 means unknown.
      */
	InfilesizeLarge = CURLOPTTYPE_OFF_T + 115,
	/* Sets the continuation offset.  There is also a CURLOPTTYPE_LONG version of this;
      * look above for RESUME_FROM.
      */
	ResumeFromLarge = CURLOPTTYPE_OFF_T + 116,
	/* Sets the maximum size of data that will be downloaded from
      * an HTTP or FTP server.  See MAXFILESIZE above for the CURLOPTTYPE_LONG version.
      */
	MaxfilesizeLarge = CURLOPTTYPE_OFF_T + 117,
	/* Set this option to the file name of your .netrc file you want libcurl
        to parse (using the CURLOPT_NETRC option). If not set, libcurl will do
        a poor attempt to find the user's home directory and check for a .netrc
        file in there. */
	NetrcFile = CURLOPTTYPE_STRINGPOINT + 118,
	/* Enable SSL/TLS for FTP, pick one of:
        CURLUSESSL_TRY     - try using SSL, proceed anyway otherwise
        CURLUSESSL_CONTROL - SSL for the control connection or fail
        CURLUSESSL_ALL     - SSL for all communication or fail
     */
	UseSsl = CURLOPTTYPE_LONG + 119,
	/* The _LARGE version of the standard POSTFIELDSIZE option */
	PostfieldsizeLarge = CURLOPTTYPE_OFF_T + 120,
	/* Enable/disable the TCP Nagle algorithm */
	TcpNodelay = CURLOPTTYPE_LONG + 121,
	/* 122 OBSOLETE, used in 7.12.3. Gone in 7.13.0 */
	/* 123 OBSOLETE. Gone in 7.16.0 */
	/* 124 OBSOLETE, used in 7.12.3. Gone in 7.13.0 */
	/* 125 OBSOLETE, used in 7.12.3. Gone in 7.13.0 */
	/* 126 OBSOLETE, used in 7.12.3. Gone in 7.13.0 */
	/* 127 OBSOLETE. Gone in 7.16.0 */
	/* 128 OBSOLETE. Gone in 7.16.0 */
	/* When FTP over SSL/TLS is selected (with CURLOPT_USE_SSL), this option
        can be used to change libcurl's default action which is to first try
        "AUTH SSL" and then "AUTH TLS" in this order, and proceed when a OK
        response has been received.
   
        Available parameters are:
        CURLFTPAUTH_DEFAULT - let libcurl decide
        CURLFTPAUTH_SSL     - try "AUTH SSL" first, then TLS
        CURLFTPAUTH_TLS     - try "AUTH TLS" first, then SSL
     */
	Ftpsslauth = CURLOPTTYPE_LONG + 129,
	Ioctlfunction = CURLOPTTYPE_FUNCTIONPOINT + 130,
	Ioctldata = CURLOPTTYPE_OBJECTPOINT + 131,
	/* 132 OBSOLETE. Gone in 7.16.0 */
	/* 133 OBSOLETE. Gone in 7.16.0 */
	/* zero terminated string for pass on to the FTP server when asked for
        "account" info */
	FtpAccount = CURLOPTTYPE_STRINGPOINT + 134,
	/* feed cookie into cookie engine */
	Cookielist = CURLOPTTYPE_STRINGPOINT + 135,
	/* ignore Content-Length */
	IgnoreContentLength = CURLOPTTYPE_LONG + 136,
	/* Set to non-zero to skip the IP address received in a 227 PASV FTP server
        response. Typically used for FTP-SSL purposes but is not restricted to
        that. libcurl will then instead use the same IP address it used for the
        control connection. */
	FtpSkipPasvIp = CURLOPTTYPE_LONG + 137,
	/* Select "file method" to use when doing FTP, see the curl_ftpmethod
        above. */
	FtpFilemethod = CURLOPTTYPE_LONG + 138,
	/* Local port number to bind the socket to */
	Localport = CURLOPTTYPE_LONG + 139,
	/* Number of ports to try, including the first one set with LOCALPORT.
        Thus, setting it to 1 will make no additional attempts but the first.
     */
	Localportrange = CURLOPTTYPE_LONG + 140,
	/* no transfer, set up connection and let application use the socket by
        extracting it with CURLINFO_LASTSOCKET */
	ConnectOnly = CURLOPTTYPE_LONG + 141,
	/* Function that will be called to convert from the
        network encoding (instead of using the iconv calls in libcurl) */
	ConvFromNetworkFunction = CURLOPTTYPE_FUNCTIONPOINT + 142,
	/* Function that will be called to convert to the
        network encoding (instead of using the iconv calls in libcurl) */
	ConvToNetworkFunction = CURLOPTTYPE_FUNCTIONPOINT + 143,
	/* Function that will be called to convert from UTF8
        (instead of using the iconv calls in libcurl)
        Note that this is used only for SSL certificate processing */
	ConvFromUtf8Function = CURLOPTTYPE_FUNCTIONPOINT + 144,
	/* if the connection proceeds too quickly then need to slow it down */
	/* limit-rate: maximum number of bytes per second to send or receive */
	MaxSendSpeedLarge = CURLOPTTYPE_OFF_T + 145,
	MaxRecvSpeedLarge = CURLOPTTYPE_OFF_T + 146,
	/* Pointer to command string to send if USER/PASS fails. */
	FtpAlternativeToUser = CURLOPTTYPE_STRINGPOINT + 147,
	/* callback function for setting socket options */
	Sockoptfunction = CURLOPTTYPE_FUNCTIONPOINT + 148,
	Sockoptdata = CURLOPTTYPE_OBJECTPOINT + 149,
	/* set to 0 to disable session ID re-use for this transfer, default is
       enabled                                                             = 1) */
	SSL_SESSIONID_CACHE = CURLOPTTYPE_LONG + 150,
	/* allowed SSH authentication methods */
	SshAuthTypes = CURLOPTTYPE_LONG + 151,
	/* Used by scp/sftp to do public/private key authentication */
	SshPublicKeyfile = CURLOPTTYPE_STRINGPOINT + 152,
	SshPrivateKeyfile = CURLOPTTYPE_STRINGPOINT + 153,
	/* Send CCC (Clear Command Channel) after authentication */
	FtpSslCcc = CURLOPTTYPE_LONG + 154,
	/* Same as TIMEOUT and CONNECTTIMEOUT, but with ms resolution */
	TimeoutMs = CURLOPTTYPE_LONG + 155,
	ConnecttimeoutMs = CURLOPTTYPE_LONG + 156,
	/* set to zero to disable the libcurl's decoding and thus pass the raw body
        data to the application even when it is encoded/compressed */
	HTTPTransferDecoding = CURLOPTTYPE_LONG + 157,
	HTTPContentDecoding = CURLOPTTYPE_LONG + 158,
	/* Permission used when creating new files and directories on the remote
        server for protocols that support it, SFTP/SCP/FILE */
	NewFilePerms = CURLOPTTYPE_LONG + 159,
	NewDirectoryPerms = CURLOPTTYPE_LONG + 160,
	/* Set the behaviour of POST when redirecting. Values must be set to one
        of CURL_REDIR* defines below. This used to be called CURLOPT_POST301 */
	Postredir = CURLOPTTYPE_LONG + 161,
	/* used by scp/sftp to verify the host's public key */
	SshHostPublicKeyMd5 = CURLOPTTYPE_STRINGPOINT + 162,
	/* Callback function for opening socket (instead of socket(2)). Optionally,
        callback is able change the address or refuse to connect returning
        CURL_SOCKET_BAD.  The callback should have type
        curl_opensocket_callback */
	Opensocketfunction = CURLOPTTYPE_FUNCTIONPOINT + 163,
	Opensocketdata = CURLOPTTYPE_OBJECTPOINT + 164,
	/* POST volatile input fields. */
	Copypostfields = CURLOPTTYPE_OBJECTPOINT + 165,
	/* set transfer mode  Type                                            =<a|i>) when doing FTP via an HTTP proxy */
	ProxyTransferMode = CURLOPTTYPE_LONG + 166,
	/* Callback function for seeking in the input stream */
	Seekfunction = CURLOPTTYPE_FUNCTIONPOINT + 167,
	Seekdata = CURLOPTTYPE_OBJECTPOINT + 168,
	/* CRL file */
	Crlfile = CURLOPTTYPE_STRINGPOINT + 169,
	/* Issuer certificate */
	Issuercert = CURLOPTTYPE_STRINGPOINT + 170,
	/* (IPv6) Address scope */
	AddressScope = CURLOPTTYPE_LONG + 171,
	/* Collect certificate chain info and allow it to get retrievable with
        CURLINFO_CERTINFO after the transfer is complete. */
	Certinfo = CURLOPTTYPE_LONG + 172,
	/* "name" and "pwd" to use when fetching. */
	Username = CURLOPTTYPE_STRINGPOINT + 173,
	Password = CURLOPTTYPE_STRINGPOINT + 174,
	/* "name" and "pwd" to use with Proxy when fetching. */
	Proxyusername = CURLOPTTYPE_STRINGPOINT + 175,
	Proxypassword = CURLOPTTYPE_STRINGPOINT + 176,
	/* Comma separated list of hostnames defining no-proxy zones. These should
        match both hostnames directly, and hostnames within a domain. For
        example, local.com will match local.com and www.local.com, but NOT
        notlocal.com or www.notlocal.com. For compatibility with other
        implementations of this, .local.com will be considered to be the same as
        local.com. A single * is the only valid wildcard, and effectively
        disables the use of proxy. */
	Noproxy = CURLOPTTYPE_STRINGPOINT + 177,
	/* block size for TFTP transfers */
	TftpBlksize = CURLOPTTYPE_LONG + 178,
	/* Socks Service */
	Socks5GssapiService = CURLOPTTYPE_STRINGPOINT + 179, /* DEPRECATED, do not use! */
	/* Socks Service */
	Socks5GssapiNec = CURLOPTTYPE_LONG + 180,
	/* set the bitmask for the protocols that are allowed to be used for the
        transfer, which thus helps the app which takes URLs from users or other
        external inputs and want to restrict what protocol(s) to deal
        with. Defaults to CURLPROTO_ALL. */
	Protocols = CURLOPTTYPE_LONG + 181,
	/* set the bitmask for the protocols that libcurl is allowed to follow to,
        as a subset of the CURLOPT_PROTOCOLS ones. That means the protocol needs
        to be set in both bitmasks to be allowed to get redirected to. Defaults
        to all protocols except FILE and SCP. */
	RedirProtocols = CURLOPTTYPE_LONG + 182,
	/* set the SSH knownhost file name to use */
	SshKnownhosts = CURLOPTTYPE_STRINGPOINT + 183,
	/* set the SSH host key callback, must point to a curl_sshkeycallback
        function */
	SshKeyfunction = CURLOPTTYPE_FUNCTIONPOINT + 184,
	/* set the SSH host key callback custom pointer */
	SshKeydata = CURLOPTTYPE_OBJECTPOINT + 185,
	/* set the SMTP mail originator */
	MailFrom = CURLOPTTYPE_STRINGPOINT + 186,
	/* set the list of SMTP mail receiver(s) */
	MailRcpt = CURLOPTTYPE_OBJECTPOINT + 187,
	/* FTP: send PRET before PASV */
	FtpUsePret = CURLOPTTYPE_LONG + 188,
	/* RTSP request method (OPTIONS, SETUP, PLAY, etc...) */
	RtspRequest = CURLOPTTYPE_LONG + 189,
	/* The RTSP session identifier */
	RtspSessionID = CURLOPTTYPE_STRINGPOINT + 190,
	/* The RTSP stream URI */
	RtspStreamUri = CURLOPTTYPE_STRINGPOINT + 191,
	/* The Transport: header to use in RTSP requests */
	RtspTransport = CURLOPTTYPE_STRINGPOINT + 192,
	/* Manually initialize the client RTSP CSeq for this handle */
	RtspClientCseq = CURLOPTTYPE_LONG + 193,
	/* Manually initialize the server RTSP CSeq for this handle */
	RtspServerCseq = CURLOPTTYPE_LONG + 194,
	/* The stream to pass to INTERLEAVEFUNCTION. */
	Interleavedata = CURLOPTTYPE_OBJECTPOINT + 195,
	/* Let the application define a custom write method for RTP data */
	Interleavefunction = CURLOPTTYPE_FUNCTIONPOINT + 196,
	/* Turn on wildcard matching */
	Wildcardmatch = CURLOPTTYPE_LONG + 197,
	/* Directory matching callback called before downloading of an
        individual file (chunk) started */
	ChunkBgnFunction = CURLOPTTYPE_FUNCTIONPOINT + 198,
	/* Directory matching callback called after the file (chunk)
        was downloaded, or skipped */
	ChunkEndFunction = CURLOPTTYPE_FUNCTIONPOINT + 199,
	/* Change match (fnmatch-like) callback for wildcard matching */
	FnmatchFunction = CURLOPTTYPE_FUNCTIONPOINT + 200,
	/* Let the application define custom chunk data pointer */
	ChunkData = CURLOPTTYPE_OBJECTPOINT + 201,
	/* FNMATCH_FUNCTION user pointer */
	FnmatchData = CURLOPTTYPE_OBJECTPOINT + 202,
	/* send linked-list of name:port:address sets */
	Resolve = CURLOPTTYPE_OBJECTPOINT + 203,
	/* Set a username for authenticated TLS */
	TlsauthUsername = CURLOPTTYPE_STRINGPOINT + 204,
	/* Set a password for authenticated TLS */
	TlsauthPassword = CURLOPTTYPE_STRINGPOINT + 205,
	/* Set authentication type for authenticated TLS */
	TlsauthType = CURLOPTTYPE_STRINGPOINT + 206,
	/* Set to 1 to enable the "TE:" header in HTTP requests to ask for
        compressed transfer-encoded responses. Set to 0 to disable the use of TE:
        in outgoing requests. The current default is 0, but it might change in a
        future libcurl release.
   
        libcurl will ask for the compressed methods it knows of, and if that
        isn't any, it will not ask for transfer-encoding at all even if this
        option is set to 1.
     */
	TransferEncoding = CURLOPTTYPE_LONG + 207,
	/* Callback function for closing socket (instead of close(2)). The callback
        should have type curl_closesocket_callback */
	Closesocketfunction = CURLOPTTYPE_FUNCTIONPOINT + 208,
	Closesocketdata = CURLOPTTYPE_OBJECTPOINT + 209,
	/* allow GSSAPI credential delegation */
	GssapiDelegation = CURLOPTTYPE_LONG + 210,
	/* Set the name servers to use for DNS resolution */
	DnsServers = CURLOPTTYPE_STRINGPOINT + 211,
	/* Time-out accept operations (currently for FTP only) after this amount
        of milliseconds. */
	AccepttimeoutMs = CURLOPTTYPE_LONG + 212,
	/* Set TCP keepalive */
	TcpKeepalive = CURLOPTTYPE_LONG + 213,
	/* non-universal keepalive knobs (Linux, AIX, HP-UX, more) */
	TcpKeepidle = CURLOPTTYPE_LONG + 214,
	TcpKeepintvl = CURLOPTTYPE_LONG + 215,
	/* Enable/disable specific SSL features with a bitmask, see CURLSSLOPT_* */
	SslOptions = CURLOPTTYPE_LONG + 216,
	/* Set the SMTP auth originator */
	MailAuth = CURLOPTTYPE_STRINGPOINT + 217,
	/* Enable/disable SASL initial response */
	SaslIr = CURLOPTTYPE_LONG + 218,
	/* Function that will be called instead of the internal progress display
      * function. This function should be defined as the curl_xferinfo_callback
      * prototype defines. (Deprecates CURLOPT_PROGRESSFUNCTION) */
	Xferinfofunction = CURLOPTTYPE_FUNCTIONPOINT + 219,
	/* The XOAUTH2 bearer token */
	Xoauth2Bearer = CURLOPTTYPE_STRINGPOINT + 220,
	/* Set the interface string to use as outgoing network
      * interface for DNS requests.
      * Only supported by the c-ares DNS backend */
	DnsInterface = CURLOPTTYPE_STRINGPOINT + 221,
	/* Set the local IPv4 address to use for outgoing DNS requests.
      * Only supported by the c-ares DNS backend */
	DnsLocalIp4 = CURLOPTTYPE_STRINGPOINT + 222,
	/* Set the local IPv4 address to use for outgoing DNS requests.
      * Only supported by the c-ares DNS backend */
	DnsLocalIp6 = CURLOPTTYPE_STRINGPOINT + 223,
	/* Set authentication options directly */
	LoginOptions = CURLOPTTYPE_STRINGPOINT + 224,
	/* Enable/disable TLS NPN extension (http2 over ssl might fail without) */
	SslEnableNpn = CURLOPTTYPE_LONG + 225,
	/* Enable/disable TLS ALPN extension (http2 over ssl might fail without) */
	SslEnableAlpn = CURLOPTTYPE_LONG + 226,
	/* Time to wait for a response to a HTTP request containing an
      * Expect: 100-continue header before sending the data anyway. */
	Expect100TimeoutMs = CURLOPTTYPE_LONG + 227,
	/* This points to a linked list of headers used for proxy requests only,
        struct curl_slist kind */
	Proxyheader = CURLOPTTYPE_OBJECTPOINT + 228,
	/* Pass in a bitmask of "header options" */
	Headeropt = CURLOPTTYPE_LONG + 229,
	/* The public key in DER form used to validate the peer public key
        this option is used only if SSL_VERIFYPEER is true */
	Pinnedpublickey = CURLOPTTYPE_STRINGPOINT + 230,
	/* Path to Unix domain socket */
	UnixSocketPath = CURLOPTTYPE_STRINGPOINT + 231,
	/* Set if we should verify the certificate status. */
	SslVerifystatus = CURLOPTTYPE_LONG + 232,
	/* Set if we should enable TLS false start. */
	SslFalsestart = CURLOPTTYPE_LONG + 233,
	/* Do not squash dot-dot sequences */
	PathAsIs = CURLOPTTYPE_LONG + 234,
	/* Proxy Service Name */
	ProxyServiceName = CURLOPTTYPE_STRINGPOINT + 235,
	/* Service Name */
	ServiceName = CURLOPTTYPE_STRINGPOINT + 236,
	/* Wait/don't wait for pipe/mutex to clarify */
	Pipewait = CURLOPTTYPE_LONG + 237,
	/* Set the protocol used when curl is given a URL without a protocol */
	DefaultProtocol = CURLOPTTYPE_STRINGPOINT + 238,
	/* Set stream weight, 1 - 256 (default is 16) */
	StreamWeight = CURLOPTTYPE_LONG + 239,
	/* Set stream dependency on another CURL handle */
	StreamDepends = CURLOPTTYPE_OBJECTPOINT + 240,
	/* Set E-xclusive stream dependency on another CURL handle */
	StreamDependsE = CURLOPTTYPE_OBJECTPOINT + 241,
	/* Do not send any tftp option requests to the server */
	TftpNoOptions = CURLOPTTYPE_LONG + 242,
	/* Linked-list of host:port:connect-to-host:connect-to-port,
        overrides the URL's host:port (only for the network layer) */
	ConnectTo = CURLOPTTYPE_OBJECTPOINT + 243,
	/* Set TCP Fast Open */
	TcpFastopen = CURLOPTTYPE_LONG + 244,
	/* Continue to send data if the server responds early with an
      * HTTP stat  code                                                    = 300 */
	KeepSendingOnError = CURLOPTTYPE_LONG + 245,
	/* The CApath or CAfile used to validate the proxy certificate
        this option is used only if PROXY_SSL_VERIFYPEER is true */
	ProxyCainfo = CURLOPTTYPE_STRINGPOINT + 246,
	/* The CApath directory used to validate the proxy certificate
        this option is used only if PROXY_SSL_VERIFYPEER is true */
	ProxyCapath = CURLOPTTYPE_STRINGPOINT + 247,
	/* Set if we should verify the proxy in ssl handshake,
        set 1 to verify. */
	ProxySslVerifypeer = CURLOPTTYPE_LONG + 248,
	/* Set if we should verify the Common name from the proxy certificate in ssl
      * handshake, set 1 to check existence, 2 to ensure that it matches
      * the provided hostname. */
	ProxySslVerifyhost = CURLOPTTYPE_LONG + 249,
	/* What version to specifically try to use for proxy.
        See CURL_SSLVERSION defines below. */
	ProxySslversion = CURLOPTTYPE_LONG + 250,
	/* Set a username for authenticated TLS for proxy */
	ProxyTlsauthUsername = CURLOPTTYPE_STRINGPOINT + 251,
	/* Set a password for authenticated TLS for proxy */
	ProxyTlsauthPassword = CURLOPTTYPE_STRINGPOINT + 252,
	/* Set authentication type for authenticated TLS for proxy */
	ProxyTlsauthType = CURLOPTTYPE_STRINGPOINT + 253,
	/* name of the file keeping your private SSL-certificate for proxy */
	ProxySslcert = CURLOPTTYPE_STRINGPOINT + 254,
	/* type of the file keeping your SSL-certificate ("DER", "PEM", "ENG") for
        proxy */
	ProxySslcerttype = CURLOPTTYPE_STRINGPOINT + 255,
	/* name of the file keeping your private SSL-key for proxy */
	ProxySslkey = CURLOPTTYPE_STRINGPOINT + 256,
	/* type of the file keeping your private SSL-key ("DER", "PEM", "ENG") for
        proxy */
	ProxySslkeytype = CURLOPTTYPE_STRINGPOINT + 257,
	/* password for the SSL private key for proxy */
	ProxyKeypasswd = CURLOPTTYPE_STRINGPOINT + 258,
	/* Specify which SSL ciphers to use for proxy */
	ProxySslCipherList = CURLOPTTYPE_STRINGPOINT + 259,
	/* CRL file for proxy */
	ProxyCrlfile = CURLOPTTYPE_STRINGPOINT + 260,
	/* Enable/disable specific SSL features with a bitmask for proxy, see
        CURLSSLOPT_* */
	ProxySslOptions = CURLOPTTYPE_LONG + 261,
	/* Name of pre proxy to use. */
	PreProxy = CURLOPTTYPE_STRINGPOINT + 262,
	/* The public key in DER form used to validate the proxy public key
        this option is used only if PROXY_SSL_VERIFYPEER is true */
	ProxyPinnedpublickey = CURLOPTTYPE_STRINGPOINT + 263,
	/* Path to an abstract Unix domain socket */
	AbstractUnixSocket = CURLOPTTYPE_STRINGPOINT + 264,
	/* Suppress proxy CONNECT response headers from user callbacks */
	SuppressConnectHeaders = CURLOPTTYPE_LONG + 265,
	LastEntry, /* the last unused */
}
