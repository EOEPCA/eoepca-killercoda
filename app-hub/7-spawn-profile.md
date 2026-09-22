
## Spawn a Profile

Go to [Start My Server]({{TRAFFIC_HOST1_83}}/hub/spawn), select **IGA - Streamlit demo** and click **Start** at the bottom of the window.

The Hub pulls the profile's image and starts a pod for `eric`. The first start takes a minute or two - the progress page redirects on its own once the server is ready.

You land on the Streamlit demo application. This profile is an ordinary web application packaged as a container image: the Hub runs it as `eric`'s server and proxies your browser to it under `/user/eric/`.
