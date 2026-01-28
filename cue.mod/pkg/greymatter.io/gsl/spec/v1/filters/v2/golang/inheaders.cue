package golang

// Greymatter Inheaders Filter Configuration
#InheadersConfig: {
	debug?: bool
}

#GreymatterInheadersFilter: #EnvoyGolangConfig & {
	// Override with inheaders values
	library_id:   "greymatter.inheaders"
	library_path: "/opt/greymatter/bin/go_filters/inheaders.so"
	plugin_name:  "greymatter.inheaders"

	// Plugin-specific configuration
	plugin_config: {
		"@type": "type.googleapis.com/xds.type.v3.TypedStruct"
		value:   #InheadersConfig
	}
}
