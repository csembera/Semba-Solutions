# Semba Solutions — landing site deploy
#
#   make deploy   sync index.html + founder-picture.jpg + tick-demo/ to S3;
#                 invalidate CloudFront
#
# Reads bucket + distribution IDs from ../Pulp/cdk/outputs.json (the landing
# site currently shares infra with the Pulp CDK stack). Override the path with
# PULP_OUTPUTS=/some/path/outputs.json, or pass BUCKET=... DIST=... directly.
#
# tick-demo/ is the public TICK demo served at /tick-demo. It ships as directory
# index files (dunder-mifflin/brief/index.html) because the landing distribution
# runs a CloudFront viewer-request function that appends /index.html to any
# extensionless URI - that is what makes /tick-demo/dunder-mifflin/brief resolve.
# The two sync passes split on content type; --delete is scoped to the tick-demo/
# prefix, so it prunes stale demo files and cannot reach index.html or
# founder-picture.jpg at the bucket root.

.PHONY: deploy

PULP_OUTPUTS ?= ../Pulp/cdk/outputs.json

deploy:
	@BUCKET="$(BUCKET)"; DIST="$(DIST)"; \
	if [ -z "$$BUCKET" ] || [ -z "$$DIST" ]; then \
	  test -f "$(PULP_OUTPUTS)" || { echo "$(PULP_OUTPUTS) missing — run 'make deploy-backend' in Pulp first, or pass BUCKET=... DIST=..."; exit 1; }; \
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
	echo "→ aws s3 sync tick-demo/ s3://$$BUCKET/tick-demo/"; \
	aws s3 sync tick-demo/ "s3://$$BUCKET/tick-demo/" \
	  --exclude "*" --include "*.html" --delete \
	  --content-type "text/html; charset=utf-8" \
	  --cache-control "no-cache, no-store, must-revalidate"; \
	aws s3 sync tick-demo/ "s3://$$BUCKET/tick-demo/" \
	  --exclude "*.html" --delete \
	  --cache-control "public, max-age=86400, must-revalidate"; \
	echo "→ aws cloudfront create-invalidation --distribution-id $$DIST --paths /index.html / /founder-picture.jpg /tick-demo/*"; \
	aws cloudfront create-invalidation --distribution-id "$$DIST" --paths '/index.html' '/' '/founder-picture.jpg' '/tick-demo/*' > /dev/null; \
	echo "Done — invalidation typically propagates within a minute."
