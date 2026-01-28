package golang

// Greymatter Audits Filter Configuration
#AuditsConfig: {
	// Required: topic for audit events
	topic:   string
	version: "v2"

	// Payload emission configuration
	payloadEmission?: {
		emitFullPayload?: bool
		base64Encode?:    bool
		maxBufferSize?:   string
	}

	// Rolling file configuration for file-based emitters (optional)
	rollingFileConfig?: {
		fileName?:       string
		maxFileSize?:    int
		maxFileBackups?: int
		maxAgeInDays?:   int
		compressFile?:   bool
	}

	// msTimestampEnabled enables milliseconds timestamp to allow better resolution for audit logs.
	// Default is true.
	msTimestampEnabled?: bool

	// OpenSearch emitter configuration (optional)
	opensearch?: {
		index: string
		servers: [...string]
		username: string
		password: string
	}
}

#GreymatterAuditsFilter: #EnvoyGolangConfig & {
	// Override with audits values
	library_id:   "greymatter.audits"
	library_path: "/opt/greymatter/bin/go_filters/audits.so"
	plugin_name:  "greymatter.audits"

	// Plugin-specific configuration
	plugin_config: {
		"@type": "type.googleapis.com/xds.type.v3.TypedStruct"
		value:   #AuditsConfig
	}
}
