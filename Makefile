# Copyright (C) 2021-2022, Vi Grey and Bigbass
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

DOC_NAME := draft-tasd-spec-0001
VERSION_DOC_NAME := tasd-spec-0001
LATEST_DOC_NAME := draft-tasd-spec
CURRENTDIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))

documents:
	mkdir -p $(CURRENTDIR)build/docs
	xml2rfc $(CURRENTDIR)src/docs/$(DOC_NAME).xml -p $(CURRENTDIR)build/docs --text --html --no-external-js --no-external-css --v3 --id-is-work-in-progress --no-pagination

contribution:
	mkdir -p $(CURRENTDIR)docs/$(VERSION_DOC_NAME)
	mkdir -p $(CURRENTDIR)docs/latest
	cp $(CURRENTDIR)build/docs/$(DOC_NAME).txt $(CURRENTDIR)docs/$(VERSION_DOC_NAME)/
	cp $(CURRENTDIR)build/docs/$(DOC_NAME).html $(CURRENTDIR)docs/$(VERSION_DOC_NAME)/
	cp $(CURRENTDIR)build/docs/$(DOC_NAME).txt $(CURRENTDIR)docs/latest/$(LATEST_DOC_NAME).txt
	cp $(CURRENTDIR)build/docs/$(DOC_NAME).html $(CURRENTDIR)docs/latest/$(LATEST_DOC_NAME).html

clean:
	rm -rf -- $(CURRENTDIR)build
