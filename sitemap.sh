#!/bin/bash

#
# sitemap.sh  0.1
#


  mkdir -p xml


  wget  -O xml/index.xml $(head -1 site.txt) -a wget.log


  gawk '

    BEGIN {
      x = 1000;
    }

    /<loc>/ {
      gsub("<[^>]+>", "");
      gsub("[ \t\n\r]+", "");
      print "echo", $0;
      print "wget -O xml/" x++ ".xml", $0, "-a wget.log";
    }

  ' xml/index.xml | sh


  gawk '

    /<loc>/ {
      gsub("<[^>]+>", "");
      gsub("[ \t\n\r]+", "");
      print $0;
    }

  ' xml/1*.xml | sort -u > xml/all-url.txt


  mkdir -p html


  gawk '

    /^http/ {
      url = of = $1;
      gsub("^.*[.]hu/", "", of);
      gsub("(^/|/$)", "",   of);
      gsub("[./]", "_",     of);
      of = "html/" of ".html"
      print url, of > "xml/html-index.txt";
      print "test -f", of, "||", "echo",    of;
      print "test -f", of, "||", "wget -O", of, url, "-a wget.log";
    }

  ' xml/all-url.txt | sh

