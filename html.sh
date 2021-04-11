#!/bin/bash

#
# html.sh  v0.2
#
# start url = site.txt first line
#

  mkdir -p flag data html error


  test -f html/_index.html || echo $(head -1 site.txt) html/_index.html > flag/_index.flag
  test -f curl.opt && CURLOPT=$(gawk '{printf "%s ", $0}' curl.opt)

  FLAG=flag/$(ls -1 flag/ | grep flag$ | head -1)
  test -f $FLAG || exit
  URL=$(cut -f 1 -d " " $FLAG)
  HTML=$(cut -f 2 -d " " $FLAG)


  echo $URL
  echo curl $CURLOPT $URL | bash > $HTML


  grep -q "html>" $HTML
  test $? -eq 0 || mv $FLAG error
  test -f $FLAG || rm $HTML
  test -f $FLAG || exit
  rm $FLAG
  echo $URL $HTML >> data/all-url.txt


  lynx --dump $HTML | gawk '

    BEGIN {
      getline < "site.txt";
      gsub("^https*:/+", "");
      gsub("/.*$", "");
      domain = $0;
      root = "https://" domain "/";
    }

######################################## sitemod

    flag && $2 ~ /(admin|account|cart|login|register)/ {
      next;
    }

######################################## sitemod

    flag && $2 ~ /[.](pdf|mp3|mp4|avi|mpg|doc|xls|zip|arj|rar)/ {
      next;
    }

    flag && $1 ~ /[0-9]+[.]/ && $2 ~ /file:/ {
      gsub("file:///",          root, $2);
      gsub("file://localhost/", root, $2);
    }

    flag && $1 ~ /[0-9]+[.]/ && $2 ~ /https*:/ {
      url = $2;
      if(!_[url]++ && index(url, domain)) {
        file = url2file(url);
        html = "html/" file ".html";
        flag = "flag/" file ".flag";
        error = "error/" file ".flag";
         if(0 < (getline < html)) {
           close(html);
         } else if(file) {
             if(1 > (getline < error)) {
               print url, html > flag;
             } else {
               close(error);
             }
         }
      }
    }

    /^References/ {
      flag++;
    }

    function url2file(s) {
      gsub("^.*https*:/+", "", s);
      gsub("^" domain "/+", "", s);
      gsub("/+$", "", s);
      gsub("[?#].*$", "", s);
      gsub("[./]", "_", s);
      return s;
    }

  '


