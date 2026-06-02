# Semba Solutions — landing site deploy
#
#   make deploy   sync index.html + founder-picture.jpg to S3; invalidate CloudFront
#
# Reads bucket + distribution IDs from ../Pulp-App/cdk/outputs.json (the landing
# site currently shares infra with the Pulp CDK stack). Override the path with
# PULP_OUTPUTS=/some/path/outputs.json, or pass BUCKET=... DIST=... directly.

.PHONY: deploy

PULP_OUTPUTS ?= ../Pulp-App/cdk/outputs.json

deploy:
	@BUCKET="$(BUCKET)"; DIST="$(DIST)"; \
	if [ -z "$$BUCKET" ] || [ -z "$$DIST" ]; then \
	  test -f "$(PULP_OUTPUTS)" || { echo "$(PULP_OUTPUTS) missing — run 'make deploy-backend' in Pulp-App first, or pass BUCKET=... DIST=..."; exit 1; }; \
	  BUCKET=$$(jq -r '.PulpAppStack.LandingBucketName' "$(PULP_OUTPUTS)"); \
	  DIST=$$(jq -r '.PulpAppStack.LandingDistributionId' "$(PULP_OUTPUTS)"); \
	fi; \
	if [ -z "$$BUCKET" ] || [ "$$BUCKET" = "null" ]; then \
	  echo "LandingBucketName not found."; exit 1; \
	fi; \
	if [ -z "$$DIST" ] || [ "$$DIST" = "null" ]; then \
	  echo "LandingDistributionId not found."; exit 1; \
	fi; \
	echo "→ aws s3 cp index.html s3://$$BUCKET/index.html"; \
	aws s3 cp index.html "s3://$$BUCKET/index.html" \
	  --content-type "text/html; charset=utf-8" \
	  --cache-control "no-cache, no-store, must-revalidate"; \
	echo "→ aws s3 cp founder-picture.jpg s3://$$BUCKET/founder-picture.jpg"; \
	aws s3 cp founder-picture.jpg "s3://$$BUCKET/founder-picture.jpg" \
	  --content-type "image/jpeg" \
	  --cache-control "public, max-age=86400, must-revalidate"; \
	echo "→ aws cloudfront create-invalidation --distribution-id $$DIST --paths /index.html / /founder-picture.jpg"; \
	aws cloudfront create-invalidation --distribution-id "$$DIST" --paths '/index.html' '/' '/founder-picture.jpg' > /dev/null; \
	echo "Done — invalidation typically propagates within a minute."
