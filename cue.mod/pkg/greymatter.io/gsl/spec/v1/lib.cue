package v1

import (
	envoy_tcp_proxy "envoyproxy.io/envoy-cue/spec/extensions/filters/network/tcp_proxy/v3"
	http_inspector "envoyproxy.io/envoy-cue/spec/extensions/filters/listener/http_inspector/v3"
	original_dst "envoyproxy.io/envoy-cue/spec/extensions/filters/listener/original_dst/v3"
	udp "envoyproxy.io/envoy-cue/spec/extensions/filters/udp/udp_proxy/v3"
	core "envoyproxy.io/envoy-cue/spec/deps/cncf/xds/go/xds/core/v3"
	matcherapi "envoyproxy.io/envoy-cue/spec/deps/cncf/xds/go/xds/type/matcher/v3"
)

#DefaultRBAC: {
	rules: {
		action: "ALLOW"
		policies: {
			all: {
				permissions: [
					{
						any: true
					},
				]
				principals: [
					{
						any: true
					},
				]
			}
		}
	}
}

#GRPCUpstream: {
	http2_protocol_options: {
		allow_connect: *true | _
	}
}

#GRPCListener: #GRPCUpstream

// DEPRECATED: please use #GRPCUpstream
#DefaultGRPCUpstream: #GRPCUpstream

#HTTP2Upstream: {
	http2_protocol_options: {}
}

#HTTP2Listener: #HTTP2Upstream

#DefaultContext: #GlobalContext & {
	mesh: {
		name:                    *"greymatter-mesh" | _
		datastore_upstream_name: *"datastore" | _
		// NOTE(alec): this field will likely be derived from 
		// the core bundle in the near future.
		operator_namespace: *"greymatter" | _
	}

	sidecar: {
		// port for ingress traffic, matching the operator 
		default_ingress_port: *10908 | _
		// use milliseconds for audits timestamps
		ms_timestamp_enabled: *true | _
	}

	spire: {
		trust_domain: *"greymatter.io" | _
	}

	edge_host: *"" | _
}

#SpireCommon: {
	#context: {
		#GlobalContext
		service_name: string
	}
	#subjects: [...string]

	secret: {
		ecdh_curves?: [...string]
		secret_validation_name: *"spiffe://\(#context.spire.trust_domain)" | _
		// // self 
		secret_name: *"spiffe://\(#context.spire.trust_domain)/\(#context.mesh.operator_namespace).\(#context.mesh.name).\(#context.namespace)-\(#context.service_name)" | _
		// other 
		subject_names: *[for s in #subjects {"spiffe://\(#context.spire.trust_domain)/\(#context.mesh.operator_namespace).\(#context.mesh.name).\(s)"}] | _
		set_current_client_cert_details: URI: *true | _
		forward_client_cert_details: *"APPEND_FORWARD" | _
	}
}

#SpireListener: {
	#SpireCommon
	force_https: *true | _
	...
}

#SpireUpstream: {
	#SpireCommon
	require_tls: true
	...
}

#TLSUpstream: #UpstreamTLSSchema & {
	require_tls: true
	ssl_config: {
		protocols: *["TLS_AUTO"] | _
	}
}

#MTLSUpstream: #UpstreamTLSSchema & {
	#TLSUpstream
	ssl_config: {
		trust_file: *"/etc/proxy/tls/sidecar/ca.crt" | _
		cert_key_pairs: *[{
			certificate_path: *"/etc/proxy/tls/sidecar/tls.crt" | _
			key_path:         *"/etc/proxy/tls/sidecar/tls.key" | _
		}] | _
	}
}

#TLSListener: #ListenerTLSSchema & {
	force_https: *true | _
	ssl_config: #ListenerSSLConfig & {
		protocols: *["TLS_AUTO"] | _
		cert_key_pairs: *[
			{
				certificate_path: *"/etc/proxy/tls/sidecar/tls.crt" | _
				key_path:         *"/etc/proxy/tls/sidecar/tls.key" | _
			},
		] | _
	}
}

#MTLSListener: #ListenerTLSSchema & {
	#TLSListener
	ssl_config: {
		trust_file:           *"/etc/proxy/tls/sidecar/ca.crt" | _
		require_client_certs: *true | _
	}
}

#ShadowTraffic: {
	behavior: "shadow"
	weight:   int
}

#SplitTraffic: {
	behavior: "split"
	weight:   int
}

// This allows for "drop in object" functionality inside upstreams. Fields are still eventually
// typed checked
#Upstream: {
	...
}

#TCPListener: {
	#TCPListenerSchema

	tcp_options: envoy_tcp_proxy.#TcpProxy & {
		// simpler to prefix here than in gpal
		cluster: ( _#makeUpstreamName & {name: upstream.name, namespace: upstream.namespace}).output
		stat_prefix: *cluster | _
	}
	audit_options?: #AuditTCPFilter.#options

	filter_order?: [...string]
	filters: [...]

	upstream: #UpstreamSchema
	protocol: "tcp"
}

#HTTPListener: {
	#TCPListenerSchema

	audit_options?: #AuditFilter.#options

	filter_order?: [...string]
	filters: [...]

	protocol: "http_auto"
	routes:   #Routes

	non_auto: true
}

#AutoEgressListener: {
	#TCPListenerSchema
	http_inspector.#HttpInspector

	audit_options?: #AuditFilter.#options
	filter_order?: [...string]
	filters: [...]
	protocol: "http_auto"
	routes:   #Routes
	domains: [...string]
	port: *10901 | _
}

#PassthroughHTTPListener: {
	#TCPListenerSchema
	original_dst.#OriginalDst

	audit_options?: #AuditFilter.#options
	filter_order?: [...string]
	filters: [...]
	protocol: "http_auto"
	domains: [...string] | *["*"]
	port: *10901 | _
	routes: {
		"/": {
			zone_key:    #DEFAULT_ZONE
			route_match: {
				match_type: *"prefix" | "exact" | "regex"
				path:       "/"
			}

			upstreams: {
				"passthrough": {
					#UpstreamSchema

					name: "passthrough"
					original_dst_lb_config: use_http_header: true
					lb_policy: "CLUSTER_PROVIDED"
					dns_type:  "ORIGINAL_DST"
				}
			}
		}
	}
}

#UDPListener: t={
	#UDPListenerSchema

	// is injected by the service layer
	stat_prefix: *t.name | _
	protocol:    "udp"
	matcher!:    #Matcher

	// Override envoy API with custom fields
	#MatchMap: {
		matcherapi.#Matcher_MatcherTree_MatchMap
		map?: [string]: {
			action?:  #MatchAction
			matcher?: #Matcher
		}
	}

	#FieldMatcher: {
		matcherapi.#Matcher_MatcherList_FieldMatcher
		on_match?: {
			action?:  #MatchAction
			matcher?: #Matcher
		}
	}

	#Matcher: {
		matcherapi.#Matcher
		on_no_match?: {
			action?:  #MatchAction
			matcher?: #Matcher
		}
		matcher_list?: matchers: [...#FieldMatcher]
		matcher_tree?: {
			exact_match_map?:  #MatchMap
			prefix_match_map?: #MatchMap
		}
	}

	#MatchAction: {
		core.#TypedExtensionConfig
		name: "route"
		typed_config: {
			udp.#Route
		}
		route_to: #UpstreamSchema
	}
}

// Ingress for telemetry collection
#Telemetry: {
	#HTTPListener
	ip:   *"0.0.0.0" | _
	port: int
	// This is set to false because Envoy will 301 redirect to https
	// since the x-forwarded-proto header will always be HTTP from
	// the original prometheus scrape request. The connection is still
	// SPIRE guarded mTLS.
	force_https: false
}

#ServiceInfo: #Telemetry & {
	ip:   *"0.0.0.0" | _
	port: *8002 | int
	routes: {
		"/stats/prometheus": {
			redirect_to_trailing_slash: false
			prefix_rewrite:             "/stats/prometheus"
			upstreams: {
				service_info: {
					#Upstream
					instances: [
						{
							host: "127.0.0.1"
							port: int | *8083
						},
					]
				}
			}
		}
	}
}

#SpireTelemetry: #Telemetry & {
	ip:   *"0.0.0.0" | _
	port: *8005 | int
	routes: {
		"/": {
			redirect_to_trailing_slash: false
			prefix_rewrite:             "/"
			upstreams: {
				spire_telemetry: {
					#Upstream
					instances: [
						{
							host: "127.0.0.1"
							port: 9988
						},
					]
				}
			}
		}
	}
}
