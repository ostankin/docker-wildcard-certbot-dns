# docker-wildcard-certbot-dns
A Docker Compose template for container-based cluster of websites that share the same IP and the same with DNS-verified Letsencrypt certificate.

## Problem statement
Modern browsers keep making the requirements for web applications more and more restrict. Not only lack of HTTPS may complicate the experience of your web application's visitors, but even using a custom port may be a problem nowadays.

While Letsencrypt makes it easy to issue and renew a TLS certificate (and even make it a wildcard one, which comes in handy for multiple subdomains), you still have little control over making sure your renewed certificates are picked up on time. The more websites you have, the more problematic it becomes to orchestrate HTTPS access for them all.

This repository provides a tool designed to solve the above problem.

## Prerequisites
1. You run a bunch of web applications on a single server (ideally using `docker-compose`, but not necessarily).
2. You own a single domain name and you can manage it's DNS records over the API of one of the providers supported by [AnalogJ Lexicon](https://github.com/AnalogJ/lexicon#supported-providers) (note: only `Route53` has been actually tested!).

## Functionality
This repository provides a `docker-compose` config for a reverse proxy (SSL proxy) that does the following:
1. Takes care of the TLS certificate.
2. Proxies all incoming requests to the corresponding applications, according to the host name.
3. Supports additional configuration for both the proxy and for the upstream applications.
4. Periodically monitors the readiness of the upstreams and takes them in or out of service depending of their reachability.

## Getting started
The repository comes with an example config for two sites.

### Configuration
Clone this repository, `cd` into it and run `./setup-example.sh` to set up the example configuration. You will need to provide the following:
* **Domain name** (by default it is `example.com`, but you want to replace it with the your domain)
* **External HTTPS port** - the port that your host will listen to for accepting HTTPS traffic
* **External HTTP port** - the port that your host will listen to for accepting HTTP traffic
* **Certbot provider** - the name of the [AnalogJ Lexicon provider](https://github.com/AnalogJ/lexicon/tree/master/lexicon/providers) that will be used to manage your domain's DNS records.

When done, the script will generate two files for you:
* **.env** - the file with the initial variables required for `docker-compose` configuration
* **config.yml** - the config with custom config for your SSL proxy and for your upstreams.

The last step you need to do yourself is to create a **.certbot-secret** file. It needs to contain all the environment variables needed to enable Lexicon to connect to your DNS provider (see [Lexicon documentation](https://dns-lexicon.readthedocs.io/en/latest/user_guide.html#environmental-variables) on environment variable names).

## Launching
Go to `docker-compose/ssl_proxy` and run the following commands:
```
docker-compose up -d
docker-compose logs -f
```
This will do two things necessary for the whole system to work:
* create a bridge network called `ssl_proxy_bridge_network` - this network enables  communication of SSL proxy with its upstreams
* bring up SSL proxy itself.

It will take some time before `certbot` container obtains the certificate. Once this is done, `nginx` container will launch and start monitoring the upstreams.

Now break output of the logs and go to `docker-compose/example-site1` and run `docker-compose up -d`  in there. Do the same for `docker-compose/example-site2`.

Once this is done, the sites should respond to HTTPS-requests (make sure to replace `yourdomain.com` with the name of the domain you provided during setup:
```
$ curl https://site1.yourdomain.com
<html>
Secure website #1
</html>
$ curl https://site2.yourdomain.com
<html>
Secure website #2, with rate limiting
</html>
```
Note that `site2` is configured to limit the request rate, so if you repeat the last command multiple times within a second, you'll see an error:
```
$ curl https://site2.yourdomain.com
<html>
<head><title>503 Service Temporarily Unavailable</title></head>
<body>
<center><h1>503 Service Temporarily Unavailable</h1></center>
<hr><center>nginx/1.19.7</center>
</body>
</html>
```
Note that rate limiting is configured on SSL proxy side - **[config.yml](https://github.com/ostankin/docker-wildcard-certbot-dns/blob/master/docker-compose/ssl_proxy/config-example.yml)** is responsible for this.

## Configuring your own sites
When the example proves to be working, the time is right to add your own upstream sites. To do so, make sure to do two things:
1. In **docker-compose.yml** add a reference to `ssl_proxy_bridge_network` (see [example](https://github.com/ostankin/docker-wildcard-certbot-dns/blob/master/docker-compose/example-site1/docker-compose.yml))
1. Edit **config.yml** to configure the upstreams and the common configuration . Each upstream has the following mandatory keys:
    * `url` - the internal URL by which the upstream container can be reached
    * `subdomain` - the name of the subdomain (added to your domain) part of the site's public URL.

It is also possible to add custom portions of `nginx` configs - on `http` level (the `common` part of **config.yml**) and on `server` level (the `include` part of each upstream config).

After making the change, make sure to recreate the `nginx` container of SSL proxy. To do so, change directory to `docker-compose/ssl_proxy` and do the following:
```
docker-compose stop nginx && docker-compose rm nginx && docker-compose up -d nginx
```

SSL proxy will check the reachability of all upstreams every 15 seconds, and it will only proxy the requests to the healthy ones, otherwise will return `404`.