.PHONY:genimage
genimage:
	git diff --name-only HEAD\^ content/posts  |\
	xargs tcardgen -o static/tcard -f assets/fonts/kinto-sans -t assets/ogp_template.png -c config/config.yml


