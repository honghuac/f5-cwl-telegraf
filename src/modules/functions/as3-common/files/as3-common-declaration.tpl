{
	"class": "AS3",
	"action": "deploy",
	"persist": true,
	"declaration": {
		"class": "ADC",
		"schemaVersion": "3.10.0",
		"remark": "Example depicting creation of BIG-IP module log profiles",
		"Common": {
			"Shared": {
				"class": "Application",
				"template": "shared",
				"telemetry_local_rule": {
					"remark": "Only required when TS is a local listener",
					"class": "iRule",
					"iRule": "when CLIENT_ACCEPTED {\n  node 127.0.0.1 6514\n}"
				},
				"telemetry_local": {
					"remark": "Only required when TS is a local listener",
					"class": "Service_TCP",
					"virtualAddresses": [
						"255.255.255.254"
					],
					"virtualPort": 6514,
					"iRules": [
						"telemetry_local_rule"
					]
				},
				"telemetry": {
					"class": "Pool",
					"members": [{
						"enable": true,
						"serverAddresses": [
							"255.255.255.254"
						],
						"servicePort": 6514
					}],
					"monitors": [{
						"bigip": "/Common/tcp"
					}]
				},
				"telemetry_hsl": {
					"class": "Log_Destination",
					"type": "remote-high-speed-log",
					"protocol": "tcp",
					"pool": {
						"use": "telemetry"
					}
				},
				"telemetry_formatted": {
					"class": "Log_Destination",
					"type": "splunk",
					"forwardTo": {
						"use": "telemetry_hsl"
					}
				},
				"telemetry_publisher": {
					"class": "Log_Publisher",
					"destinations": [{
						"use": "telemetry_formatted"
					}]
				},
				"telemetry_traffic_log_profile": {
					"class": "Traffic_Log_Profile",
					"requestSettings": {
						"requestEnabled": true,
						"requestProtocol": "mds-tcp",
						"requestPool": {
							"use": "telemetry"
						},
						"requestTemplate": "event_source=\"request_logging\",hostname=\"$BIGIP_HOSTNAME\",client_ip=\"$CLIENT_IP\",server_ip=\"$SERVER_IP\",http_method=\"$HTTP_METHOD\",http_uri=\"$HTTP_URI\",virtual_name=\"$VIRTUAL_NAME\",date_time=\"$DATE_HTTP\""
					}
				},
				"telemetry_security_log_profile": {
					"class": "Security_Log_Profile",
					"application": {
						"localStorage": false,
						"remoteStorage": "splunk",
						"protocol": "tcp",
						"servers": [{
							"address": "255.255.255.254",
							"port": "6514"
						}],
						"storageFilter": {
							"requestType": "illegal-including-staged-signatures"
						}
					}
				}
			}
		}
	}
}
