# Semba Solutions

Landing site for [Semba Solutions](https://sembasolutions.com), a static page
hosted on AWS S3 and served through CloudFront.

## Contents

- `index.html` the landing page (self-contained; styles are inline)
- `founder-picture.jpg` about-section photo
- `Makefile` deploy target

## Deploy

```sh
make deploy
```

This syncs `index.html` and `founder-picture.jpg` to S3 and invalidates the
CloudFront cache.

## Note

Portions of this code were generated with the help of AI.
