package v1


// KubeService models a Kubernetes Service
#KubeService: {
	annotations?: [string]: string
	labels?: [string]:      string

	externalIPs?: [string]
	clusterIP?: string
	clusterIPs?: [string]

	// https://kubernetes.io/docs/reference/networking/virtual-ips/#traffic-policies
	trafficDistribution?:   string
	internalTrafficPolicy?: "Cluster" | "Local"
	externalTrafficPolicy?: "Cluster" | "Local"

	// Client stickiness -> controls routing requests to specific backends.
	// K8s defaults to "None" so this is a safe default.
	sessionAffinity: *"None" | "ClientIP"
	sessionAffinityConfig?: {
		// In seconds
		timeout: int
	}
	healthCheckNodePort?:      int32
	publishNotReadyAddresses?: bool
}
// Gateway definition serves as a light abstraction over K8s Service and similar networking resources.
// Users can set use #Gateways on #Edge definitions.
#Gateway: {
	// All currently supported ingress types are defined here.
	// A "type" is required.
	type!: "LoadBalancer" | "ClusterIP" | "NodePort" | "ExternalName" | "OpenshiftRoute"

	#KubeService
	targetListeners?: [...#TargetListener]
}

// TargetListeners expect a name which which maps to a ingress/egress listener.
// The exposedPort becomes the open port on the deployed k8s service.
#TargetListener: {
	name:         string
	exposedPort?: int
}

// https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer
#LoadBalancer: {
	#Gateway
	type: "LoadBalancer"

	lbClass?: string

	// https://kubernetes.io/docs/concepts/services-networking/service/#load-balancer-nodeport-allocation
	allocateLbNodePorts?: bool
}

// https://kubernetes.io/docs/concepts/services-networking/service/#type-clusterip
#ClusterIP: {
	#Gateway
	type: "ClusterIP"
}

// https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport
#NodePort: {
	#Gateway
	type: "NodePort"

	nodePort?: int
}

// https://kubernetes.io/docs/concepts/services-networking/service/#externalname
#ExternalName: {
	#Gateway

	type:         "ExternalName"
	externalName: string
}

// An Openshift Route is a type of networking object that we bundle with a ClusterIP, hence the KubeService def.
// https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/network_apis/route-route-openshift-io-v1
#OpenshiftRoute: {
	#KubeService
	type: "OpenshiftRoute"

	host: string
	targetListener: string
}
