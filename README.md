# Squid proxy server for AWS

Setup a Squid proxy server to run on EC2 through a static EIP so that AWS-hosted Kubernetes pods can communicate with on-prem servers.

## Usage

Create a password for the default `proxy` user locally for mounting in the container:

```
echo -n passw0rd > $(pwd)/users/proxy
```

Bring up the proxy server and test it:

```
docker-compose up squid
export http_proxy=http://127.0.0.1:3128
curl -x http://proxy:passw0rd@127.0.0.1:3128 http://example.org
```
