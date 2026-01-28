package online_boutique

import (
	gsl "greymatter.io/gsl/spec/v1"
	"online-boutique.module/greymatter:globals"
)

cartservice: gsl.#Service & {
	context: cartservice.#NewContext & globals

	name:            "cartservice"
	display_name:    "Online Boutique Cartservice"
	version:         "v1.0.0"
	description:     "No description"
	business_impact: "low"
	owner:           "online-boutique"
	capability:      ""
	api_endpoint:    ""

	resources: gsl.#ResourceQuotas & {
		requests: {
			cpu:    "100m"
			memory: "128Mi"
		}
		limits: {
			cpu:    "200m"
			memory: "200Mi"
		}
	}

	ingress: {
		"cartservice": {
			gsl.#HTTPListener
			gsl.#HTTP2Listener
			gsl.#SpireListener & {
				#context: context.SpireContext
				#subjects: ["online-boutique-checkoutservice", "online-boutique-frontend"]
			}

			routes: {
				"/": {
					upstreams: {
						"127.0.0.1:7070": {
							gsl.#Upstream
							gsl.#HTTP2Upstream

							instances: [
								{
									host: "127.0.0.1"
									port: 7070
								},
							]
						}
					}
				}
			}
		}

		"service-info": gsl.#ServiceInfo & {
			gsl.#SpireListener & {
				#context: context.SpireContext
				#subjects: ["prometheus"]
			}
		}
	}

	egress: {
		"redis-cart": {
			gsl.#TCPListener

			port: 6379

			upstream: {
				gsl.#Upstream
				gsl.#SpireUpstream & {
					#context: context.SpireContext
					#subjects: ["online-boutique-redis-cart"]
				}

				name:            "redis-cart"
				namespace:       "online-boutique"
				target_listener: "redis-cart"
			}
		}
	}
}

exports: "cartservice": cartservice
