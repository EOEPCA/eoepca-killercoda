
## Spawn a Profile

Go to the [Application Hub home]({{TRAFFIC_HOST1_83}}/) and click **Start My Server**.

The **Server Options** page now lists the profiles available to `eric`'s groups. Select **IGA - Streamlit demo** and click **Start** at the bottom of the window.

The Hub pulls the profile's image and starts a pod for `eric`. The first start takes a minute or two - the progress page redirects on its own once the server is ready.

You should land on a Streamlit dashboard. The profile is an ordinary web application packaged as a container image: the Hub runs it as your server and proxies your browser to it under `/user/eric/`.

> Use the profiles named in this tutorial. The other profiles in the list pull images that this tutorial environment cannot unpack.
