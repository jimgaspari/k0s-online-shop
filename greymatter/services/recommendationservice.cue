package online_boutique

import (
	gsl "greymatter.io/gsl/spec/v1"
	"online-boutique.module/greymatter:globals"
)

recommendationservice: gsl.#Service & {
	context: recommendationservice.#NewContext & globals

	name:            "recommendationservice"
	display_name:    "Online Boutique Recommendationservice"
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
		"recommendationservice": {
			gsl.#HTTPListener
			gsl.#HTTP2Listener
			gsl.#SpireListener & {
				#context: context.SpireContext
				#subjects: ["online-boutique-frontend"]
			}

			routes: {
				"/": {
					upstreams: {
						"127.0.0.1:8080": {
							gsl.#Upstream
							gsl.#HTTP2Upstream

							instances: [
								{
									host: "127.0.0.1"
									port: 8080
								},
							]
						}
					}
				}
			}
		}
		"health-probes": {
			gsl.#HTTPListener
			gsl.#GRPCListener
			port:10911
			// Mark the listener to remap container probes
			health_probes: {
				readiness: gsl.#ContainerProbe
				liveness:  gsl.#ContainerProbe
			}

			routes: {
				"/": {
					upstreams: {
						"health-probes": {
							gsl.#Upstream
							gsl.#GRPCUpstream
							instances: [
								{
									host: "127.0.0.1"
									port: 8080
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
		"productcatalogservice": {
			gsl.#AutoEgressListener
			gsl.#HTTP2Listener

			custom_headers: [
				{
					key:   "x-forwarded-proto"
					value: "https"
				},
			]

			domains: [
				"productcatalogservice:3550",
			]

			routes: {
				"/": {
					prefix_rewrite: "/"

					upstreams: {
						"productcatalogservice": {
							gsl.#Upstream
							gsl.#HTTP2Upstream
							gsl.#SpireUpstream & {
								#context: context.SpireContext
								#subjects: ["online-boutique-productcatalogservice"]
							}

							namespace:       "online-boutique"
							target_listener: "productcatalogservice"
						}
					}
				}
			}
		}
	}
}

exports: "recommendationservice": recommendationservice
