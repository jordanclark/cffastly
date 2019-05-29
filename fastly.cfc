component {
	cfprocessingdirective( preserveCase=true );

	function init(
		required string token
	,	string apiUrl= "https://api.fastly.com"
	,	numeric httpTimeOut= 120
	,	boolean debug= ( request.debug ?: false )
	) {
		this.token= arguments.token;
		this.apiUrl= arguments.apiUrl;
		this.httpTimeOut = arguments.httpTimeOut;
		this.debug= arguments.debug;
		this.defaultServiceID= "";
		this.defaultVersion= "";
		this.defaultPoolID= "";
		this.userAgent= "fastly-cfml-api-client/1.6.1";
		return this;
	}

	struct function getServices() {
		return this.apiRequest( api= "GET /service" );
	}

	function getService(required string id= this.defaultServiceID) {
		return this.apiRequest( api= "GET /service/{id}/details", argumentCollection= arguments );
	}

	function purgeURL(required string url) {
		return this.apiRequest( api= "PURGE {url}", argumentCollection= arguments );
	}

	function softPurgeURL(required string url) {
		// todo: add Fastly-Soft-Purge:1 header 
		return this.apiRequest( api= "PURGE {url}", argumentCollection= arguments );
	}

	function purgeAll(required string service_id= this.defaultServiceID) {
		return this.apiRequest( api= "POST /service/{service_id}/purge_all", argumentCollection= arguments );
	}

	function purgeKey(required string service_id= this.defaultServiceID, required string key) {
		return this.apiRequest( api= "POST /service/{service_id}/purge/{key}", argumentCollection= arguments );
	}

	function purgeKeys(required string service_id= this.defaultServiceID, required surrogate_keys) {
		if ( isSimpleValue( arguments.surrogate_keys ) ) {
			arguments.surrogate_keys= listToArray( arguments.surrogate_keys, " " );
		}
		return this.apiRequest( api= "POST /service/{service_id}/purge", argumentCollection= arguments );
	}

	function softPurgeKeys(required string service_id= this.defaultServiceID, required string key) {
		// todo: add Fastly-Soft-Purge:1 header 
		return this.apiRequest( api= "POST /service/{service_id}/purge/{key}", argumentCollection= arguments );
	}

	function edgeCheck(required string url) {
		return this.apiRequest( api= "GET /content/edge_check?url={url}", argumentCollection= arguments );
	}

	function listPools(required string service_id= this.defaultServiceID, required string version= this.defaultVersion) {
		return this.apiRequest( api= "GET /service/{service_id}/version/{version}/pool", argumentCollection= arguments );
	}

	function getPool(
		required string service_id= this.defaultServiceID
	,	required string version= this.defaultVersion
	,	required string pool_name
	) {
		return this.apiRequest( api= "GET /service/{service_id}/version/{version}/pool/{pool_name}", argumentCollection= arguments );
	}

	function createPool(
		required string service_id= this.defaultServiceID
	,	required string version= this.defaultVersion
	,	required string name
	,	string comment
	,	string shield= "null"
	,	string use_tls= 0
	,	string type
	,	string request_condition
	,	string max_conn_default= 200
	,	string connect_timeout
	,	string first_byte_timeout
	,	string quorum= 75
	,	string tls_ca_cert
	,	string tls_ciphers
	,	string tls_client_key
	,	string tls_client_cert
	,	string tls_sni_hostname
	,	string tls_check_cert
	,	string tls_cert_hostname
	,	string min_tls_version
	,	string max_tls_version
	,	string healthcheck
	) {
		return this.apiRequest( api= "POST /service/{service_id}/version/{version}/pool", argumentCollection= arguments );
	}

	function updatePool(
		required string service_id= this.defaultServiceID
	,	required string version= this.defaultVersion
	,	required string pool_name
	,	string name
	,	string comment
	,	string shield
	,	string use_tls
	,	string type
	,	string request_condition
	,	string max_conn_default
	,	string connect_timeout
	,	string first_byte_timeout
	,	string quorum
	,	string tls_ca_cert
	,	string tls_ciphers
	,	string tls_client_key
	,	string tls_client_cert
	,	string tls_sni_hostname
	,	string tls_check_cert
	,	string tls_cert_hostname
	,	string min_tls_version
	,	string max_tls_version
	,	string healthcheck
	) {
		return this.apiRequest( api= "PUT /service/{service_id}/version/{version}/pool/{pool_name}", argumentCollection= arguments );
	}

	function deletePool(
		required string service_id= this.defaultServiceID
	,	required string version= this.defaultVersion
	,	required string pool_name
	) {
		return this.apiRequest( api= "DELETE /service/{service_id}/version/{version}/pool/{pool_name}", argumentCollection= arguments );
	}

	function listServers(
		required string service_id= this.defaultServiceID
	,	required string pool_id= this.defaultPoolID
	) {
		return this.apiRequest( api= "GET /service/{service_id}/pool/{pool_id}/servers", argumentCollection= arguments );
	}

	function getServer(
		required string service_id= this.defaultServiceID
	,	required string pool_id= this.defaultPoolID
	,	required string server_id
	) {
		return this.apiRequest( api= "GET /service/{service_id}/pool/{pool_id}/server/{server_id}", argumentCollection= arguments );
	}

	function createServer(
		required string service_id= this.defaultServiceID
	,	required string pool_id= this.defaultPoolID
	,	string weight
	,	string max_conn
	,	string port
	,	string address
	,	string comment
	,	boolean disabled
	) {
		return this.apiRequest( api= "POST /service/{service_id}/pool/{pool_id}/server", argumentCollection= arguments );
	}

	function updateServer(
		required string service_id= this.defaultServiceID
	,	required string pool_id= this.defaultPoolID
	,	required string server_id
	,	string weight
	,	string max_conn
	,	string port
	,	string address
	,	string comment
	,	boolean disabled) {
		return this.apiRequest( api= "PUT /service/{service_id}/pool/{pool_id}/server/{server_id}", argumentCollection= arguments );
	}

	function deleteServer(
		required string service_id= this.defaultServiceID
	,	required string pool_id= this.defaultPoolID
	,	required string server_id
	) {
		return this.apiRequest( api= "DELETE /service/{service_id}/pool/{pool_id}/server/{server_id}", argumentCollection= arguments );
	}

	struct function apiRequest(required string api) {
		var http= {};
		var item= "";
		var out= {
			args= arguments
		,	success= false
		,	error= ""
		,	status= ""
		,	statusCode= 0
		,	response= ""
		,	verb= listFirst( arguments.api, " " )
		,	requestUrl= ""
		};
		out.requestUrl &= listRest( out.args.api, " " );
		structDelete( out.args, "api" );
		//  replace {var} in url 
		for ( item in out.args ) {
			//  strip NULL values 
			if ( isNull( out.args[ item ] ) ) {
				structDelete( out.args, item );
			} else if ( isSimpleValue( arguments[ item ] ) && arguments[ item ] == "null" ) {
				arguments[ item ]= javaCast( "null", 0 );
			} else if ( findNoCase( "{#item#}", out.requestUrl ) ) {
				out.requestUrl= replaceNoCase( out.requestUrl, "{#item#}", out.args[ item ], "all" );
				structDelete( out.args, item );
			}
		}
		if ( out.verb == "GET" ) {
			out.requestUrl &= structToQueryString( out.args, true );
		} else if ( !structIsEmpty( out.args ) ) {
			out.body= serializeJSON( out.args );
		}
		if ( left( out.requestURL, 4 ) != "http" ) {
			out.requestUrl= this.apiUrl & out.requestUrl;
		}
		this.debugLog( "API: #uCase( out.verb )#: #out.requestUrl#" );
		if ( structKeyExists( out, "body" ) ) {
			this.debugLog( out.body );
		}
		if ( this.debug ) {
			this.debugLog( out );
		}
		cftimer( type="debug", label="fastly request" ) {
			cfhttp( result="http", method=out.verb, url=out.requestUrl, throwOnError=false, userAgent=this.userAgent, timeOut=this.httpTimeOut, charset="UTF-8" ) {
				cfhttpparam( name="Fastly-Key", type="header", value=this.token );
				cfhttpparam( name="Accept", type="header", value="application/json" );
				if ( out.verb == "POST" || out.verb == "PUT" || out.verb == "PATCH" ) {
					//  OR out.verb IS "PURGE"
					cfhttpparam( name="Content-Type", type="header", value="application/json" );
				}
				if ( structKeyExists( out, "body" ) ) {
					cfhttpparam( type="body", value=out.body );
				}
			}
		}
		// this.debugLog( response );
		out.response= toString( http.fileContent );
		if ( this.debug ) {
			this.debugLog( out.response );
		}
		//  RESPONSE CODE ERRORS 
		if ( !structKeyExists( response, "responseHeader" ) || !structKeyExists( http.responseHeader, "Status_Code" ) || http.responseHeader.Status_Code == "" ) {
			out.statusCode= 500;
		} else {
			out.statusCode= http.responseHeader.Status_Code;
		}
		this.debugLog( out.statusCode );
		if ( left( out.statusCode, 1 ) == 4 || left( out.statusCode, 1 ) == 5 ) {
			out.success= false;
			out.error= "status code error: #out.statusCode#";
		} else if ( out.response == "Connection Timeout" || out.response == "Connection Failure" ) {
			out.error= out.response;
		} else if ( left( out.statusCode, 1 ) == 2 ) {
			out.success= true;
		}
		//  parse response 
		if ( !len( out.error ) ) {
			try {
				out.response= deserializeJSON( out.response );
				if ( isNull( out.response ) ) {
					out.response= "";
				}
				if ( isStruct( out.response ) && structKeyExists( out.response, "error" ) ) {
					out.error= out.response.error;
				} else if ( isStruct( out.response ) && structKeyExists( out.response, "status" ) && out.response.status == 400 ) {
					out.error= out.response.detail;
				} else if ( isStruct( out.response ) && structKeyExists( out.response, "message" ) && find( "already exists", out.response.message ) && out.statusCode == 409 ) {
					out.success= true;
					out.error= "";
					out.response= out.response.message;
				}
			} catch (any cfcatch) {
				out.error= "JSON Error: " & cfcatch.message;
			}
		}
		if ( len( out.error ) ) {
			out.success= false;
		}
		return out;
	}

	function debugLog(required input) {
		if ( structKeyExists( request, "log" ) && isCustomFunction( request.log ) ) {
			if ( isSimpleValue( arguments.input ) ) {
				request.log( "fastly: " & arguments.input );
			} else {
				request.log( "fastly: (complex type)" );
				request.log( arguments.input );
			}
		} else if ( this.debug ) {
			cftrace( text=( isSimpleValue( arguments.input ) ? arguments.input : "" ), var=arguments.input, category="fastly", type="information" );
		}
		return;
	}

	string function structToQueryString(required struct stInput, boolean bEncode= true) {
		var sOutput= "";
		var sItem= "";
		var sValue= "";
		var amp= "?";
		for ( sItem in stInput ) {
			if ( !isNull( stInput[ sItem ] ) ) {
				sValue= stInput[ sItem ];
				if ( bEncode ) {
					sOutput &= amp & sItem & "=" & urlEncodedFormat( sValue );
				} else {
					sOutput &= amp & sItem & "=" & sValue;
				}
				amp= "&";
			}
		}
		return sOutput;
	}

}