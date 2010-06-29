If there are any stats existing at the time of running specs that have the same name as those used in the specs, the specs outcome will be skewed and the spec will fail.
Also, spec should remove it's garbage when its done. It currently leaves files sitting in the stats dir.
