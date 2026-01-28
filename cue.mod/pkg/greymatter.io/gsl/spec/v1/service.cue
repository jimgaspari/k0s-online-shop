package v1

#Service: {
	#NewContext: {
		globals: #GlobalContext
		SpireContext: {
			globals
			service_name: name
		}
	}
	context: #NewContext

	// Embed k8s pod spec fields -- get added to the sidecar
	#PodSpec

	type:                      #ObjectType | *#TypeService
	zone_key:                  #DEFAULT_ZONE
	name:                      string
	namespace:                 string | *context.globals.namespace
	mesh_id:                   string | *context.globals.mesh.name
	service_id:                name
	api_endpoint?:             string
	api_spec_endpoint?:        string
	description?:              string
	enable_instance_metrics:   bool | *false
	enable_historical_metrics: bool | *false
	business_impact:           string | *"low"
	version?:                  string
	owner?:                    string
	owner_url?:                string
	capability?:               string
	runtime?:                  string
	documentation?:            string
	prometheus_job:            string | *"\(namespace)-\(name)"
	external_links?: [...{title: string, url: string}]
	// custom field that maps to the name displayed on the dashboard
	display_name?: string
	// Controls whether the proxy's listeners supports websocket connections. Applies to all listeners if enabled.
	upgrades?: string

	ingress?: [ListenerName=string]: #Ingress & {name: ListenerName}
	egress?: [ListenerName=string]: #Egress & {name: ListenerName}

	// a raw upstream is an upstream that is not attached to a listener through a route or otherwise. It exists primarily
	// to support the pattern Envoy uses in filters where clusters are referenced by name. For instance, 
	// the external authorization filter uses a cluster defined elsewhere to locate the external authorization service. 
	// For these instances, the upstream does not require a listener or a route. They are "raw" and attached directly onto the service.
	raw_upstreams: [upstream_name=string]: {
		#UpstreamSchema

		name: upstream_name
	}

	edge?: #EdgeConfig

	// Instantiate and enforce the main listener. This listener can be discovered by Control and runs the audits filter
	// Main listeners are named after the service.
	ingress: "\(name)": #MainIngress & {
		port: *context.globals.sidecar.default_ingress_port | _
	}

	ingress?: "service-info"?: #ServiceInfo & {
		audit_options: topic: "\(name)-service-info"
	}

	ingress?: "spire-telemetry"?: #SpireTelemetry & {
		audit_options: topic: "\(name)-spire-telemetry"
	}

	egress?: "auto"?: #AutoEgressListener

	// Internal Schemas
	// These are embedded so that they can reference data found in the Service defintion
	// These are meant for internal use only and should not be used in the service definition.
	#MainIngress: #MainHTTPIngress | #MainTCPIngress | #MainUDPIngress

	#MainHTTPIngress: {
		#HTTPIngress
	}

	#MainTCPIngress: {
		#TCPIngress
	}

	#MainUDPIngress: #UDPIngress

	#TCPIngress: #TCPListener & {
		audit_options: topic: *name | _
	}

	#HTTPIngress: #HTTPListener & {
		audit_options: topic: *name | _
	}

	#UDPIngress: #UDPListener

	#Ingress: (#HTTPIngress | #TCPIngress | #UDPIngress) & {
		ip: *"0.0.0.0" | _
	}

	#Egress: (#HTTPListener | #TCPListener | #UDPListener | #AutoEgressListener | #PassthroughHTTPListener) & {
		ip: *"127.0.0.1" | _
	}
}

// EdgeConfig is used in the service definition
// to link services to their application edge node.
#EdgeConfig: {
	edge_ingress: *edge_name | string
	edge_name:    string
	routes:       #Routes
}
