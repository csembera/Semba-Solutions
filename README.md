# Semba Solutions

Landing site for [Semba Solutions](https://sembasolutions.com), a static page
hosted on AWS S3 and served through CloudFront.

## Contents

- `index.html` the landing page (self-contained; styles are inline)
- `founder-picture.jpg` about-section photo
- `tick-demo/` the public TICK demo, served at `/tick-demo` and linked from the
  products section of the landing page. Self-contained HTML built on fictional
  data (Dunder Mifflin); the account form posts to Pulp's join-request endpoint.
- `Makefile` deploy target

## Deploy

```sh
make deploy
```

This syncs `index.html`, `founder-picture.jpg` and `tick-demo/` to S3 and
invalidates the CloudFront cache.

`tick-demo/` uses directory index files, so `/tick-demo/dunder-mifflin/brief`
resolves to `dunder-mifflin/brief/index.html`. That rewrite happens in a
CloudFront viewer-request function defined on the landing distribution in the
Pulp CDK stack, not here - the paths in these pages are root-absolute and only
work when served from that distribution.

## Note

Portions of this code were generated with the help of AI.
