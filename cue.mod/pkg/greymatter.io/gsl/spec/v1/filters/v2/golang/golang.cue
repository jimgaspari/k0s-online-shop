package golang

// Note: Envoy core types would be imported here if needed
// import envoy "envoyproxy.io/envoy-cue/spec/config/core/v3"

// Envoy Golang Filter Configuration
// Manual definition since v3alpha is not available in envoy-cue at this time
#EnvoyGolangConfig: {
	// Required fields for Envoy Golang filter
	library_id:   string
	library_path: string
	plugin_name:  string

	// Optional configuration
	plugin_config?: {
		"@type": "type.googleapis.com/xds.type.v3.TypedStruct"
		value: {...}
	}
}
