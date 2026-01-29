package online_boutique

import (
	gsl "greymatter.io/gsl/spec/v1"
	"online-boutique.module/greymatter:globals"
)

checkoutservice: gsl.#Service & {
	context: checkoutservice.#NewContext & globals

	name:            "checkoutservice"
	display_name:    "Online Boutique Checkoutservice"
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
		"checkoutservice": {
			gsl.#HTTPListener
			gsl.#HTTP2Listener
			gsl.#SpireListener & {
				#context: context.SpireContext
				#subjects: ["online-boutique-frontend"]
			}

			routes: {
				"/": {
					upstreams: {
						"127.0.0.1:5050": {
							gsl.#Upstream
							gsl.#HTTP2Upstream

							instances: [
								{
									host: "127.0.0.1"
									port: 5050
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
									port: 5050
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
		"cartservice": {
			gsl.#AutoEgressListener
			gsl.#HTTP2Listener

			custom_headers: [
				{
					key:   "x-forwarded-proto"
					value: "https"
				},
			]

			domains: [
				"cartservice:7070",
			]

			routes: {
				"/": {
					prefix_rewrite: "/"

					upstreams: {
						"cartservice": {
							gsl.#Upstream
							gsl.#HTTP2Upstream
							gsl.#SpireUpstream & {
								#context: context.SpireContext
								#subjects: ["online-boutique-cartservice"]
							}

							namespace:       "online-boutique"
							target_listener: "cartservice"
						}
					}
				}
			}
		}

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

		"paymentservice": {
			gsl.#AutoEgressListener
			gsl.#HTTP2Listener

			custom_headers: [
				{
					key:   "x-forwarded-proto"
					value: "https"
				},
			]

			domains: [
				"paymentservice:50051",
			]

			routes: {
				"/": {
					prefix_rewrite: "/"

					upstreams: {
						"paymentservice": {
							gsl.#Upstream
							gsl.#HTTP2Upstream
							gsl.#SpireUpstream & {
								#context: context.SpireContext
								#subjects: ["online-boutique-paymentservice"]
							}

							namespace:       "online-boutique"
							target_listener: "paymentservice"
						}
					}
				}
			}
		}

		"shippingservice": {
			gsl.#AutoEgressListener
			gsl.#HTTP2Listener

			custom_headers: [
				{
					key:   "x-forwarded-proto"
					value: "https"
				},
			]

			domains: [
				"shippingservice:50051",
			]

			routes: {
				"/": {
					prefix_rewrite: "/"

					upstreams: {
						"shippingservice": {
							gsl.#Upstream
							gsl.#HTTP2Upstream
							gsl.#SpireUpstream & {
								#context: context.SpireContext
								#subjects: ["online-boutique-shippingservice"]
							}

							namespace:       "online-boutique"
							target_listener: "shippingservice"
						}
					}
				}
			}
		}

		"currencyservice": {
			gsl.#AutoEgressListener
			gsl.#HTTP2Listener

			custom_headers: [
				{
					key:   "x-forwarded-proto"
					value: "https"
				},
			]

			domains: [
				"currencyservice:7000",
			]

			routes: {
				"/": {
					prefix_rewrite: "/"

					upstreams: {
						"currencyservice": {
							gsl.#Upstream
							gsl.#HTTP2Upstream
							gsl.#SpireUpstream & {
								#context: context.SpireContext
								#subjects: ["online-boutique-currencyservice"]
							}

							namespace:       "online-boutique"
							target_listener: "currencyservice"
						}
					}
				}
			}
		}

		"emailservice": {
			gsl.#AutoEgressListener
			gsl.#HTTP2Listener

			custom_headers: [
				{
					key:   "x-forwarded-proto"
					value: "https"
				},
			]

			domains: [
				"emailservice:5000",
			]

			routes: {
				"/": {
					prefix_rewrite: "/"

					upstreams: {
						"emailservice": {
							gsl.#Upstream
							gsl.#HTTP2Upstream
							gsl.#SpireUpstream & {
								#context: context.SpireContext
								#subjects: ["online-boutique-emailservice"]
							}

							namespace:       "online-boutique"
							target_listener: "emailservice"
						}
					}
				}
			}
		}
	}
}

exports: "checkoutservice": checkoutservice
