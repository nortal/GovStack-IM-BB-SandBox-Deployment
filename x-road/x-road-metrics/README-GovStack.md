GovStack X-Road Metrics

X-Road Metrics project is incorporated in GovStack as a service usage data collection 
utility. The full X-Road Metrics project is available at 
https://github.com/nordic-institute/X-Road-Metrics. For GovStack purposes only a subset of 
the X-Road Metrics project is used. The subset includes:

* X-Road Metrics Collector - for retrieving operational data from X-Road Security Server
about the actual usage of messaging-api
* X-Road Metrics Corrector - cleanup of raw data and constructing of monitoring metrics 
database collection

X-Road Metrics applications, written in Python, are packaged as Docker images. The collector
image is run as a Kubernetes CronJob with an interval set with the .Values.cronjob.schedule 
parameter. The corrector module is deployed as a daemon application running in the 
background. Corrector module is run in a separate docker image as a python daemon process.
The application will periodically try to match all request/response objects and move the
refined service usage data to `clean_data` collection in X-Road metrics database module 
(MongoDB).

Data collection is based on X-Road Security Server operational monitoring data. Therefore, 
the collector module requires access to all security servers that are covered by X-Road 
Metrics for GovStack. The collector module additionally requires access to the X-Road 
GovStack sandbox Central Server to gather information about connected Security Servers
and the database module to publish the collected raw data. Corrector module requires
access only to the database module.

Depending on system load, collector run interval and data quality, the operational 
monitoring data from Security Servers can be collected with a delay up to 7 days. And
depending on the delays set in Corrector configuration it can take up to 3 days for
Corrector to process the data.
