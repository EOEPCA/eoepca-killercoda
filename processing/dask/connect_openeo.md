
Now that our OpenEO backend is deployed, let's connect to it using the OpenEO Python client. First, install the client:

```bash
pip install openeo
```

Create a simple Python script to test the connection:

```bash
cat <<'EOF' > test_connection.py
import openeo

# Connect to the backend
connection = openeo.connect("http://openeo.eoepca.local")

# Print backend information
print("Backend version:", connection.describe_account())
print("\nAvailable collections:")
for collection in connection.list_collections():
    print(f"  - {collection['id']}: {collection.get('title', 'No title')}")

print("\nAvailable processes:")
processes = connection.list_processes()
for process in processes[:10]:  # Show first 10
    print(f"  - {process['id']}: {process.get('summary', 'No summary')}")
EOF
```

Run the connection test:

```bash
python test_connection.py
```

This shows us the backend is operational and we can interact with it via the OpenEO client libraries.

For interactive work, you could also use a Jupyter notebook. Let's create a simple example:

```bash
cat <<'EOF' > openeo_example.ipynb
{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import openeo\n",
    "connection = openeo.connect('http://openeo.eoepca.local')\n",
    "connection"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF
```

The OpenEO API is now ready to accept processing requests!