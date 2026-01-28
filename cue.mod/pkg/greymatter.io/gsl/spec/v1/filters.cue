package v1

import (
	"regexp"
	"list"
	http "greymatter.io/gsl/spec/v1/filters/v1/http"
	network "greymatter.io/gsl/spec/v1/filters/v1/network"
	example "greymatter.io/gsl/spec/v1/filters/v2/example"
	golang "greymatter.io/gsl/spec/v1/filters/v2/golang"

	// envoy http filter imports
	envoy_rbac "envoyproxy.io/envoy-cue/spec/extensions/filters/http/rbac/v3"
	envoy_ratelimit "envoyproxy.io/envoy-cue/spec/extensions/filters/network/ratelimit/v3"
	envoy_jwt_authn "envoyproxy.io/envoy-cue/spec/extensions/filters/http/jwt_authn/v3"
	envoy_fault "envoyproxy.io/envoy-cue/spec/extensions/filters/http/fault/v3"
	envoy_ext_authz "envoyproxy.io/envoy-cue/spec/extensions/filters/http/ext_authz/v3"
	envoy_http_lua "envoyproxy.io/envoy-cue/spec/extensions/filters/http/lua/v3"
	envoy_buffer "envoyproxy.io/envoy-cue/spec/extensions/filters/http/buffer/v3"
	envoy_csrf "envoyproxy.io/envoy-cue/spec/extensions/filters/http/csrf/v3"
	envoy_grpc_json_transcoder "envoyproxy.io/envoy-cue/spec/extensions/filters/http/grpc_json_transcoder/v3"
	envoy_health_check "envoyproxy.io/envoy-cue/spec/extensions/filters/http/health_check/v3"
	envoy_ip_tagging "envoyproxy.io/envoy-cue/spec/extensions/filters/http/ip_tagging/v3"
	envoy_header_to_metadata "envoyproxy.io/envoy-cue/spec/extensions/filters/http/header_to_metadata/v3"
	envoy_cors "envoyproxy.io/envoy-cue/spec/extensions/filters/http/cors/v3"
	envoy_grpc_http_bridge "envoyproxy.io/envoy-cue/spec/extensions/filters/http/grpc_http1_bridge/v3"
	envoy_grpc_http_reverse_bridge "envoyproxy.io/envoy-cue/spec/extensions/filters/http/grpc_http1_reverse_bridge/v3"
	envoy_grpc_web "envoyproxy.io/envoy-cue/spec/extensions/filters/http/grpc_web/v3"
	envoy_grpc_stats "envoyproxy.io/envoy-cue/spec/extensions/filters/http/grpc_stats/v3"
	envoy_dynamic_forward_proxy "envoyproxy.io/envoy-cue/spec/extensions/filters/http/dynamic_forward_proxy/v3"
	envoy_original_src "envoyproxy.io/envoy-cue/spec/extensions/filters/http/original_src/v3"
	envoy_compressor "envoyproxy.io/envoy-cue/spec/extensions/filters/http/compressor/v3"
	envoy_on_demand "envoyproxy.io/envoy-cue/spec/extensions/filters/http/on_demand/v3"
	envoy_adaptive_concurrency "envoyproxy.io/envoy-cue/spec/extensions/filters/http/adaptive_concurrency/v3"
	envoy_tap "envoyproxy.io/envoy-cue/spec/extensions/filters/http/tap/v3"
	envoy_aws_lambda "envoyproxy.io/envoy-cue/spec/extensions/filters/http/aws_lambda/v3"
	envoy_aws_request_signing "envoyproxy.io/envoy-cue/spec/extensions/filters/http/aws_request_signing/v3"
	envoy_gzip "envoyproxy.io/envoy-cue/spec/extensions/filters/http/gzip/v3"
	envoy_local_rate_limit "envoyproxy.io/envoy-cue/spec/extensions/filters/http/local_ratelimit/v3"
	envoy_http_cache "envoyproxy.io/envoy-cue/spec/extensions/filters/http/cache/v3"
	envoy_bandwidth "envoyproxy.io/envoy-cue/spec/extensions/filters/http/bandwidth_limit/v3"
	envoy_oauth2 "envoyproxy.io/envoy-cue/spec/extensions/filters/http/oauth2/v3"
	envoy_wasm "envoyproxy.io/envoy-cue/spec/extensions/filters/http/wasm/v3"

	// envoy network filter imports
	envoy_tcp_rbac "envoyproxy.io/envoy-cue/spec/extensions/filters/network/rbac/v3"
	envoy_tcp_proxy "envoyproxy.io/envoy-cue/spec/extensions/filters/network/tcp_proxy/v3"
	envoy_redis_proxy "envoyproxy.io/envoy-cue/spec/extensions/filters/network/redis_proxy/v3"
	envoy_mongo_proxy "envoyproxy.io/envoy-cue/spec/extensions/filters/network/mongo_proxy/v3"
	envoy_tcp_rate_limit "envoyproxy.io/envoy-cue/spec/extensions/filters/network/ratelimit/v3"
	envoy_echo "envoyproxy.io/envoy-cue/spec/extensions/filters/network/echo/v3"
	envoy_sni_cluster "envoyproxy.io/envoy-cue/spec/extensions/filters/network/sni_cluster/v3"
	envoy_dubbo_proxy "envoyproxy.io/envoy-cue/spec/extensions/filters/network/dubbo_proxy/v3"
	envoy_thrift_proxy "envoyproxy.io/envoy-cue/spec/extensions/filters/network/thrift_proxy/v3"
	envoy_direct_response "envoyproxy.io/envoy-cue/spec/extensions/filters/network/direct_response/v3"
	envoy_zookeeper_proxy "envoyproxy.io/envoy-cue/spec/extensions/filters/network/zookeeper_proxy/v3"
	envoy_ext_authz_tcp "envoyproxy.io/envoy-cue/spec/extensions/filters/network/ext_authz/v3"
	envoy_tcp_local_rate_limit "envoyproxy.io/envoy-cue/spec/extensions/filters/network/local_ratelimit/v3"
	envoy_wasm_tcp "envoyproxy.io/envoy-cue/spec/extensions/filters/network/wasm/v3"

	envoy "envoyproxy.io/envoy-cue/spec/config/core/v3"
)

// helper - returns all the labels in `from` that are found in `matching`
_#copyFields: {
	from: {...}
	matching: {}

	output: {
		for k, v in from {
			if (matching & {"\(k)": v}) != _|_ {
				"\(k)": v
			}
		}
	}
}

//TCP Filters
#TCPFilters: {
	"envoy_direct_response"?: envoy_direct_response.#Config
	"envoy_dubbo_proxy"?:     envoy_dubbo_proxy.#DubboProxy
	"envoy_echo"?:            envoy_echo.#Echo
	"envoy_ext_authz"?:       envoy_ext_authz_tcp.#ExtAuthz
	"gm_jwtsecurity"?:        network.#JwtSecurityTcpConfig
	"gm_logger"?:             network.#TcpLoggerConfig
	"envoy_mongo_proxy"?:     envoy_mongo_proxy.#MongoProxy
	"gm_observables"?:        network.#ObservablesTCPConfig
	"envoy_rate_limit"?:      envoy_tcp_rate_limit.#RateLimit
	"envoy_local_ratelimit"?: envoy_tcp_local_rate_limit.#LocalRateLimit
	"envoy_rbac"?:            envoy_tcp_rbac.#RBAC
	"envoy_redis_proxy"?:     envoy_redis_proxy.#RedisProxy
	"envoy_sni_cluster"?:     envoy_sni_cluster.#SniCluster
	"envoy_tcp_proxy":        envoy_tcp_proxy.#TcpProxy
	"envoy_thrift_proxy"?:    envoy_thrift_proxy.#ThriftProxy
	"envoy_wasm"?:            envoy_wasm_tcp.#Wasm
	"envoy_zookeeper_proxy"?: envoy_zookeeper_proxy.#ZooKeeperProxy
}

#DirectResponseFilter: {
	#options: envoy_direct_response.#Config
	config:   #options
	name:     "direct_response"
}

#DubboProxyFilter: {
	#options: envoy_dubbo_proxy.#DubboProxy
	config:   #options
	name:     "dubbo_proxy"
}
#EchoFilter: {
	#options: envoy_echo.#Echo
	config:   #options
	name:     "echo"
}
#MongoProxyFilter: {
	#options: envoy_mongo_proxy.#MongoProxy
	config:   #options
	name:     "mongo_proxy"
}
#RedisProxyFilter: {
	#options: envoy_redis_proxy.#RedisProxy
	config:   #options
	name:     "redis_proxy"
}
#SNIClusterFilter: {
	#options: envoy_sni_cluster.#SniCluster
	config:   #options
	name:     "sni_cluster"
}
#ExtAuthZTCPFilter: {
	#options: envoy_ext_authz_tcp.#ExtAuthz
	config:   #options
	name:     "external_authz"
}
#JWTSecurityTCPFilter: {
	#options: network.#JwtSecurityTcpConfig
	config:   #options
	name:     "jwtsecurity"
}
#LoggerConfigTCPFilter: {
	#options: network.#TcpLoggerConfig
	config:   #options
	name:     "logger"
}
#AuditTCPFilter: {
	#options: network.#ObservablesTCPConfig
	config:   #options
	name:     "audit"
}
#RBACTCPFilter: {
	#options: envoy_tcp_rbac.#RBAC
	config:   #options
	name:     "rbac"
}
#RateLimitTCPFilter: {
	#options: envoy_tcp_rate_limit.#RateLimit
	config:   #options
	name:     "rate_limit"
}

#LocalRateLimitTCPFilter: {
	#options: envoy_tcp_local_rate_limit.#LocalRateLimit
	config:   #options
	name:     "local_rate_limit"
}

#TCPProxyFilter: {
	// special filter
	envoy_tcp_proxy.#TcpProxy
	name: "tcp_proxy"
}
#ThriftProxyFilter: {
	#options: envoy_thrift_proxy.#ThriftProxy

	config: #options
	name:   "thrift_proxy"
}
#ZookeeperProxyFilter: {
	#options: envoy_zookeeper_proxy.#ZooKeeperProxy
	config:   #options
	name:     "zookeeper_proxy"
}
#WasmTCPFilter: {
	#options: envoy_wasm_tcp.#Wasm
	config:   #options
	name:     "wasm"
}

// example noop filter
#NoopFilter: {
	#options: example.#NoopFilterConfig
	config:   #options
	name:     "noop"
}

// HTTP FILTERS
#HTTPFilters: {
	"envoy_adaptive_concurrency"?:      envoy_adaptive_concurrency.#AdaptiveConcurrency
	"envoy_aws_lambda"?:                envoy_aws_lambda.#Config
	"envoy_aws_request_signing"?:       envoy_aws_request_signing.#AwsRequestSigning
	"envoy_buffer"?:                    envoy_buffer.#Buffer
	"envoy_cache"?:                     envoy_http_cache.#CacheConfig
	"envoy_compressor"?:                envoy_compressor.#Compressor
	"envoy_cors"?:                      envoy_cors.#Cors
	"envoy_csrf"?:                      envoy_csrf.#CsrfPolicy
	"envoy_dynamic_forward_proxy"?:     envoy_dynamic_forward_proxy.#FilterConfig
	"envoy_ext_authz"?:                 envoy_ext_authz.#ExtAuthz
	"envoy_fault"?:                     envoy_fault.#HTTPFault
	"envoy_grpc_http1_bridge"?:         envoy_grpc_http_bridge.#Config
	"envoy_grpc_http1_reverse_bridge"?: envoy_grpc_http_reverse_bridge.#FilterConfig
	"envoy_grpc_json_transcoder"?:      envoy_grpc_json_transcoder.#GrpcJsonTranscoder
	"envoy_grpc_stats"?:                envoy_grpc_stats.#FilterConfig
	"envoy_grpc_web"?:                  envoy_grpc_web.#GrpcWeb
	"envoy_gzip"?:                      envoy_gzip.#Gzip
	"envoy_header_to_metadata"?:        envoy_header_to_metadata.#Config
	"envoy_health_check"?:              envoy_health_check.#HealthCheck
	"envoy_ip_tagging"?:                envoy_ip_tagging.#IPTagging
	"envoy_jwt_authn"?:                 envoy_jwt_authn.#JwtAuthentication
	"envoy_lua"?:                       envoy_http_lua.#Lua
	"envoy_on_demand"?:                 envoy_on_demand.#OnDemand
	"envoy_original_src"?:              envoy_original_src.#OriginalSrc
	"envoy_rate_limit"?:                envoy_ratelimit.#RateLimit
	"envoy_local_ratelimit"?:           envoy_local_rate_limit.#LocalRateLimit
	"envoy_rbac"?:                      envoy_rbac.#RBAC
	"envoy_tap"?:                       envoy_tap.#Tap
	"envoy_bandwidth_limit"?:           envoy_bandwidth.#BandwidthLimit
	"envoy_oauth2"?:                    envoy_oauth2.#OAuth2
	"envoy_wasm"?:                      envoy_wasm.#Wasm
	"envoy_golang"?:                    golang.#EnvoyGolangConfig
	"greymatter_inheaders"?:            golang.#GreymatterInheadersFilter
	"greymatter_audits"?:               golang.#GreymatterAuditsFilter
	"gm_ensure-variables"?:             http.#EnsureVariablesConfig
	"gm_impersonation"?:                http.#ImpersonationConfig
	"gm_inheaders"?:                    http.#InheadersConfig
	"gm_jwtsecurity"?:                  http.#GmJwtSecurityConfig
	"gm_list-auth"?:                    http.#ListAuthConfig
	"gm_oauth"?:                        http.#OauthConfig
	"gm_obfuscate"?:                    http.#ObfuscateConfig
	"gm_observables"?:                  http.#ObservablesConfig
	"gm_oidc-authentication"?:          http.#AuthenticationConfig
	"gm_oidc-validation"?:              http.#ValidationConfig
	"gm_policy"?:                       http.#PolicyConfig
}

#CacheFilter: {
	#options: envoy_http_cache.#CacheConfig & {
		typed_config: {
			type_url: "type.googleapis.com/envoy.extensions.http.cache.simple_http_cache.v3.SimpleHttpCacheConfig"
		}
	}
	config: #options
	name:   "cache"
}

#LocalRateLimitFilter: {
	#options: envoy_local_rate_limit.#LocalRateLimit
	config:   #options
	name:     "local_rate_limit"
}

#JwtSecurityFilter: {
	#options: http.#GmJwtSecurityConfig
	config:   #options
	name:     "jwtsecurity"
}

#JwtAuthenticationFilter: {
	#options: envoy_jwt_authn.#JwtAuthentication
	config:   #options
	name:     "jwt_authn"
}

#OIDCPipelineFilter: {
	#options: {
		#OIDCAuthenticationFilter.#options

		//custom configuation
		provider_cluster: string
		domain:           *regexp.FindSubmatch(#"^https?://(([\w\d-]+\.)+[\w]+)/?"#, #options.serviceUrl)[1] | ""

		idToken: http.#AuthenticationConfig_TokenStorage & {
			location: *"cookie" | _
			key:      *"id_token" | _
			cookieOptions: {
				domain:   *#options.domain | _
				secure:   *true | _
				httpOnly: *false | _
				path:     *"/" | _
			}

		}

		accessToken: http.#AuthenticationConfig_TokenStorage & {
			location: *"cookie" | _
			key:      *"access_token" | _
			cookieOptions: {
				domain:   *#options.domain | _
				secure:   *true | _
				httpOnly: *false | _
				path:     *"/" | _
			}
		}
		callbackPath: *"/oauth" | _
		additionalScopes: *["openid"] | _

		//jwt authn exposed configuration
		jwt: j = {
			envoy_jwt_authn.#JwtAuthentication

			remote_jwks: *{
				http_uri: {
					cluster: *#options.provider_cluster | _
					uri:     _provider_host + "/protocol/openid-connect/certs"
					timeout: *"1s" | _
				}
			} | envoy_jwt_authn.#RemoteJwks
			local_jwks?: envoy.#DataSource
			providers: provider: {
				forward: *true | _
				from_cookies: [accessToken.key]
				payload_in_metadata: *"claims" | _
				issuer:              *_provider_host | _
				audiences: *[#options.clientId] | _
				if j.local_jwks != _|_ {
					local_jwks: j.local_jwks
				}
				if j.local_jwks == _|_ {
					remote_jwks: j.remote_jwks
				}
			}
			rules: *[
				{
					match: {prefix: "/"}
					requires: {provider_name: "provider"}
				},
			] | _
		}

		// validation exposed configuration
		enforce: *true | _
		userInfo: {
			location: *"header" | _
			key:      "FROM"
			claims: *["email"] | _
		}
		enforceResponseCode: *401 | _
	}

	_provider_host: "\(#options.provider_host)/\(#options.authRealms)/\(#options.realm)"

	// this makes me sad
	lua: envoy_http_lua.#Lua & {
		// Use Lua pattern matching to get the user's email from encoded JSON object.
		inline_code: *"""
				function envoy_on_request(handle)
					local user_email = handle:headers():get('FROM')
					parsed_user_email = string.match(user_email, '%%7B%%22email%%22:%%22(.*)%%22%%7D')
					parsed_user_email = string.gsub(parsed_user_email, '%%20', ' ')
					handle:headers():replace('FROM', parsed_user_email)
				end
			""" | _
	}

	config: [_oidc_authn, _oidc_validate, _jwt_authn, _lua]
	// intermediate values
	_oidc_authn: {
		name: "oidc_authn"
		config: http.#AuthenticationConfig & {
			(_#copyFields & {
				from:     #options
				matching: http.#AuthenticationConfig
			}).output
			#options.tls
			provider: *_provider_host | _
		}
		secrets: #secrets
	}

	_oidc_validate: {
		name: "oidc_validate"
		config: http.#ValidationConfig & {
			TLSConfig: {
				useTLS: true
				#options.tls
			}

			userInfo:            #options.userInfo
			enforce:             #options.enforce
			enforceResponseCode: #options.enforceResponseCode
			provider:            *_provider_host | _
			accessToken: {
				key:        *#options.accessToken.key | _
				location:   *#options.accessToken.location | _
				cookiePath: *#options.accessToken.cookieOptions.path | _
			}
		}
	}

	_jwt_authn: {
		name: "jwt_authn"
		config: envoy_jwt_authn.#JwtAuthentication & (_#copyFields & {
			from:     #options.jwt
			matching: envoy_jwt_authn.#JwtAuthentication
		}).output
	}

	_lua: {
		name:   "lua"
		config: lua
	}

	#secrets: _#OIDCAuthenticationSecrets
}

_#OIDCAuthenticationSecrets: {
	client_secret!: #FilterSecret & {
		filter: #OIDCAuthenticationFilter.name
		path:   "clientSecret"
	}
}
#OIDCAuthenticationFilter: {
	#options: {
		//custom
		provider_host:  string
		_provider_host: "\(provider_host)/\(authRealms)/\(realm)"
		r = realm:      string
		keycloak: {
			pre17: *false | bool
		}
		tls: {
			useTLS:             *true | bool
			certPath?:          string
			keyPath?:           string
			caPath?:            string
			insecureSkipVerify: *false | bool
		}

		if keycloak.pre17 {
			authRealms:      "auth/realms"
			authAdminRealms: "auth/admin/realms"
		}

		// required
		additionalScopes: [...string]
		clientId:        string
		authRealms:      *"realms" | string
		authAdminRealms: *"admin/realms" | string
		callbackPath?:   string
		serviceUrl:      string

		tokenRefresh: http.#AuthenticationConfig_TokenRefreshConfig & {
			enabled: *true | _
			// provider host without realm is required, the URL with realm
			// we get constructed by jwtkeycloak in gm-proxy
			endpoint: *provider_host | _
			realm:    *r | _
			useTLS:   *true | _
			// make optional in case token refresh tls certs are different
			for k, v in tls {
				"\(k)": *v | _
			}
			timeoutMs: t
		}
		t = timeoutMs: *1000 | _

		// escape hatch
		http.#AuthenticationConfig
	}
	#secrets: _#OIDCAuthenticationSecrets

	config: http.#AuthenticationConfig & {
		#options.tls
		provider: "\(#options.provider_host)/\(#options.authRealms)/\(#options.realm)"
		(_#copyFields & {from: #options, matching: http.#AuthenticationConfig}).output
	}
	name:    "oidc_authn"
	secrets: #secrets
}

#OIDCValidationFilter: {
	#options: {
		provider: string
		enforce:  *true | bool
		TLSConfig: {
			useTLS:             *true | _
			insecureSkipVerify: *false | _
		}
	}
	filters: http.#ValidationConfig & {
		#options
	}
	name: "oidc_validate"
}

// // envoy http extension filters
#LuaFilter: {
	#options: envoy_http_lua.#Lua
	config:   #options
	name:     "lua"
}
#RBACFilter: {
	#options: envoy_rbac.#RBAC
	config:   #options
	name:     "rbac"
}
#RateLimitFilter: {
	#options: envoy_ratelimit.#RateLimit
	config:   #options
	name:     "rate_limit"
}
#FaultInjectionFilter: {
	#options: envoy_fault.#HTTPFault
	config:   #options
	name:     "fault"
}
#InheadersFilter: {
	#options: http.#InheadersConfig
	config:   #options
	name:     "inheaders"
}
#ImpersonationFilter: {
	#options: http.#ImpersonationConfig
	config:   #options
	name:     "impersonation"
}
#EnsureVariablesFilter: {
	#options: http.#EnsureVariablesConfig
	config:   #options
	name:     "ensure_variables"
}
#ListAuthFilter: {
	#options: http.#ListAuthConfig
	config:   #options
	name:     "list_auth"
}
#ObfuscateFilter: {
	#options: http.#ObfuscateConfig
	config:   #options
	name:     "obfuscate"
}
#PolicyFilter: {
	#options: http.#PolicyConfig
	config:   #options
	name:     "policy"
}
#OAuthFilter: {
	#options: http.#OauthConfig
	config:   #options
	name:     "oauth"
}
#AuditFilter: {
	#options: *http.#ObservablesConfig | golang.#AuditsConfig
	config:   #options
	name:     "audit"
}
#CSRFFilter: {
	#options: envoy_csrf.#CsrfPolicy
	config:   #options
	name:     "csrf"
}
#GRPCJSONTranscoderFilter: {
	#options: envoy_grpc_json_transcoder.#GrpcJsonTranscoder
	config:   #options
	name:     "grpc_json_transcoder"
}
#HealthCheckFilter: {
	#options: envoy_health_check.#HealthCheck
	config:   #options
	name:     "health_checks"
}
#IPTaggingFilter: {
	#options: envoy_ip_tagging.#IPTagging
	config:   #options
	name:     "ip_tagging"
}
#HeaderToMetadataFilter: {
	#options: envoy_header_to_metadata.#Config
	config:   #options
	name:     "header_to_metadata"
}
#CorsFilter: {
	#options: envoy_cors.#Cors
	config:   #options
	name:     "cors"
}
#GRPCHTTP1BridgeFilter: {
	#options: envoy_grpc_http_bridge.#Config
	config:   #options
	name:     "grpc_http1_bridge"
}
#GRPCWebFilter: {
	#options: envoy_grpc_web.#GrpcWeb
	config:   #options
	name:     "grpc_web"
}
#GRPCStatsFilter: {
	#options: envoy_grpc_stats.#FilterConfig
	config:   #options
	name:     "grpc_stats"
}
#DynamicForwardProxyFilter: {
	#options: envoy_dynamic_forward_proxy.#FilterConfig
	config:   #options
	name:     "dynamic_forward_proxy"
}
#OriginalSourceFilter: {
	#options: envoy_original_src.#OriginalSrc
	config:   #options
	name:     "original_src"
}
#GRPCHTTP1ReverseBridgeFilter: {
	#options: envoy_grpc_http_reverse_bridge.#FilterConfig
	config:   #options
	name:     "grpc_http1_reverse_bridge"
}
#CompressorFilter: {
	#options: envoy_compressor.#Compressor
	config:   #options
	name:     "compressor"
}
#OnDemandFilter: {
	#options: envoy_on_demand.#OnDemand
	config:   #options
	name:     "on_demand"
}
#AdaptiveConcurrencyFilter: {
	#options: envoy_adaptive_concurrency.#AdaptiveConcurrency
	config:   #options
	name:     "adaptive_concurrency"
}
#TapFilter: {
	#options: envoy_tap.#Tap
	config:   #options
	name:     "tap"
}
#AWSLambdaFilter: {
	#options: envoy_aws_lambda.#Config
	config:   #options
	name:     "aws_lambda"
}
#AWSRequestSigningFilter: {
	#options: envoy_aws_request_signing.#AwsRequestSigning
	config:   #options
	name:     "aws_request_signing"
}
#GZIPFilter: {
	#options: envoy_gzip.#Gzip
	config:   #options
	name:     "gzip"
}
#BufferFilter: {
	#options: envoy_buffer.#Buffer
	config:   #options
	name:     "buffer"
}
#BandwidthLimitFilter: {
	#options: envoy_bandwidth.#BandwidthLimit
	config:   #options
	name:     "bandwidth_limit"
}
#OAuth2Filter: {
	#options: envoy_oauth2.#OAuth2
	config:   #options
	name:     "oauth2"
}
#WasmFilter: {
	#options: envoy_wasm.#Wasm
	config:   #options
	name:     "wasm"
}

#GolangFilter: {
	#options: golang.#EnvoyGolangConfig
	config:   #options
	name:     "golang"
}

#GreymatterInheadersFilter: {
	#options: golang.#GreymatterInheadersFilter
	config:   #options
	name:     "greymatter_inheaders"
}

#GreymatterAuditsFilter: {
	#options: golang.#GreymatterAuditsFilter
	config:   #options
	name:     "greymatter_audits"
}

#WafCorazaFilter: {
	#WasmFilter & {
		#options: {
			config: {
				name: "coraza-filter"
				vm_config: {
					vm_id:   "coraza-filter_vm_id"
					runtime: "envoy.wasm.runtime.v8"
					code: local: filename: "/opt/greymatter/bin/coraza-proxy-wasm.wasm"
				}
				configuration: coraza_config
			}
		}
	}
	coraza_config?: _
}

#DefaultWaf: #WafCorazaFilter & {
	coraza_config: {
		"@type": "type.googleapis.com/google.protobuf.StringValue"
		value: """
			    {
			        "directives_map": {
			            "default": [
			                "SecRuleEngine DetectionOnly",
			                "SecRequestBodyAccess On",
			                "SecResponseBodyAccess Off",
			                "SecRequestBodyLimit 13107200",
			                "SecRequestBodyNoFilesLimit 131072",
			                "SecAuditEngine RelevantOnly",
							"SecAuditLogParts ABDEFHIJKZ",
			                "SecAuditLogFormat JSON",
			                "Include @crs-setup-conf",
			                "Include @owasp_crs/*.conf",
						    "SecRuleRemoveById 942100",
						    "SecRule REQUEST_COOKIES|!REQUEST_COOKIES:/__utm/|REQUEST_COOKIES_NAMES|REQUEST_HEADERS:User-Agent|REQUEST_HEADERS:Referer|ARGS_NAMES|ARGS|XML:/* \\"@detectSQLi\\" \\"id:942100,phase:2,block,capture,t:none,t:utf8toUnicode,t:urlDecodeUni,t:removeNulls,msg:'SQL Injection Attack Detected via libinjection',logdata:'Matched Data: %{TX.0} found within %{MATCHED_VAR_NAME}: %{MATCHED_VAR}',tag:'application-multi',tag:'language-multi',tag:'platform-multi',tag:'attack-sqli',tag:'paranoia-level/1',tag:'OWASP_CRS',tag:'OWASP_CRS/ATTACK-SQLI',tag:'capec/1000/152/248/66',tag:'PCI/6.5.2',ver:'OWASP_CRS/4.14.0',severity:'CRITICAL',setvar:'tx.inbound_anomaly_score_pl1=+%{tx.critical_anomaly_score}',setvar:'tx.sql_injection_score=+%{tx.critical_anomaly_score}'\\""
			            ]
			        },
			        "default_directives": "default"
			    }
			"""
	}
}

#OIDCPipelineV2: self = {
	#options: {
		oauth2: #OAuth2Filter.#options
		jwt:    #JwtAuthenticationFilter.#options
	}

	lua: envoy_http_lua.#Lua & {
		// Use Lua pattern matching to get the user's email from encoded JSON object.
		inline_code: *"""

					local function dec(data)
						local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
						data = string.gsub(data, '[^'..b..'=]', '')
						return (data:gsub('.', function(x)
						    if (x == '=') then return '' end
						    local r,f='',(b:find(x)-1)
						    for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
						    return r;
						end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
						    if (#x ~= 8) then return '' end
						    local c=0
						    for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
						    return string.char(c)
						end))
					end
					function envoy_on_request(request_handle)
					    local cookie_header = request_handle:headers():get("cookie")
					    if cookie_header then
						local id_token = cookie_header:match("IdToken=([^;]+)")
						if id_token then
						    local parts = {}
						    for part in string.gmatch(id_token, "([^%.]+)") do
							table.insert(parts, part)
						    end
						    
						    if #parts == 3 then
							-- Add padding if necessary
							local payload = parts[2]
							local padding = 4 - ((#payload) % 4)
							if padding ~= 4 then
							    payload = payload .. string.rep('=', padding)
							end
							local decoded_payload = dec(payload)
							local email = decoded_payload:match('\"email\":\"([^\"]+)\"')
							if email then
							    request_handle:headers():add('FROM', email)
							end
						    else
							request_handle:logInfo("Invalid JWT format")
						    end
						end
					    end
					end
			""" | _
	}

	config: [
		{
			#OAuth2Filter
			#options: self.#options.oauth2
		},
		{
			#JwtAuthenticationFilter
			#options: self.#options.jwt
		},
		{
			#LuaFilter
			#options: lua
		},

	]

}

#ExternalAuthzFilter: {
	#options: envoy_ext_authz.#ExtAuthz
	config:   #options
	name:     "external_authz"
}

#OPAFilter: {
	#options: {
		{
			discovered_host: {
				// Note: TLS should be configured on the cluster linking OPA with the service
				service_name: string
				namespace:    string
				authority?:   string // envoy defaults this to the cluster_name
			}
		} | {
			static_host: {
				target_uri:  string
				stat_prefix: string
				envoy.#GrpcService_GoogleGrpc
			}
		}

		failure_mode_allow: *false | _
		//escape hatch
		envoy_ext_authz.#ExtAuthz
	}
	name: "external_authz"
	config: envoy_ext_authz.#ExtAuthz & {
		transport_api_version: "V3"
		// skip custom fields, only copy fields found in #ExtAuthz
		for k, v in #options if !list.Contains(["discovered_host", "static_host", "request_timeout"], k) {
			(k): v
		}

		grpc_service: {
			if #options.discovered_host != _|_ {
				envoy_grpc: this = {
					if #options.discovered_host.namespace == "" {
						cluster_name: #options.discovered_host.service_name
					}

					if #options.discovered_host.namespace != "" {
						cluster_name: "\(#options.discovered_host.namespace)-\(#options.discovered_host.service_name)"
					}
					authority: *#options.discovered_host.authority | this.cluster_name
				}
			}
			if #options.static_host != _|_ {
				google_grpc: {
					#options.static_host
				}
			}
		}
	}

}
